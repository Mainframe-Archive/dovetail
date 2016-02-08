defmodule Dovetail do
  @moduledoc """
  The `Dovetail` module provides the public API and OTP application
  implementation.

  When the application `:dovetail` is started, its supervision ensures that
  dovecot is configured and running. The dovecot server is stopped with the
  application.

  ## Install

  `Dovetail.config/0` must be run before first starting dovecot. The `:dovecot`
  application ensures configuration, otherwise it must be done explicitly:

      iex> Dovetail.config(); :ok
      :ok

  ## Examples

      iex> Dovetail.up?
      false
      iex> Dovetail.start()
      :ok
      iex> Dovetail.up?
      true
      iex> Dovetail.stop()
      :ok
      iex> Dovetail.up?
      false

  """

  alias Dovetail.Process
  alias Dovetail.UserStore
  alias Dovetail.Config

  require Logger

  # TODO - this should be defined elsewhere
  @dovecot Application.app_dir(:dovetail, "priv/dovecot/sbin/dovecot")
  @pass_db Application.app_dir(:dovetail, "pass.db")

  # await defaults
  @timeout 5000
  @interval 50
  @await_opts [timeout: @timeout, interval: @interval]

  ## Application Callbacks

  @doc """
  Start the dovecot application.

  Despite the naming conflict, this function is semantically distinct from `start/0`
  and `start/1`.
  """
  def start(_type, _args) do
    Dovetail.Supervisor.start_link()
  end

  ## Public Functions

  @doc """
  Check if dovecot is up.
  """
  def up?(options \\ []) do
    case Process.pgrep(["-f", Keyword.get(options, :path, @dovecot)]) do
      {:ok, _}    -> true
      {:error, _} -> false
    end
  end

  @doc """
  Start the dovecot server with the default settings. This function is


  ## Options

   * `:config :: String.t` the path to the config file
   * `:await` :: Keyword.t | false` default [], if a keyword,
     use as `await/1`
  """
  @spec start(Keyword.t) :: :ok | {:error, :already_started}
  def start(opts \\ []) do
    Logger.debug("Dovecot: starting...")
    case Process.dovecot(["-c", Dict.get(opts, :config,
                                         Config.target_path())]) do
      {:ok, ""} ->
        if await_opts = Dict.get(opts, :await, @await_opts) do
          await(await_opts)
        else
          :ok
        end
      {:error, {:status, 89}} -> {:error, :already_started}
      {:error, reason}        -> {:error, reason}
    end
  end

  @doc """
  Await for the dovecot server to start.

  ## Options

   * `:timeout :: int` default #{inspect @timeout}, the amount of time in ms
     to await dovecot
   * `:interval :: interval` default #{inspect @interval}, the interval time
     in ms between dovecot status polls
  """
  def await(opts \\ []) do
    await(Dict.get(opts, :timeout, @timeout),
          Dict.get(opts, :interval, 50),
          0)
  end

  defp await(timeout, interval, count) when count * interval > timeout do
    {:error, :timeout}
  end
  defp await(timeout, interval, count) do
    if up? do
      Logger.debug("Dovecot: up!")
      :ok
    else
      receive do after interval ->
          await(timeout, interval, count + 1)
      end
    end
  end

  @doc """
  Start the dovecot server with the default settings.

  See `doveadm(["stop"])`.
  """
  def stop do
    Logger.debug("Dovecot: stopping...")
    case Process.doveadm(["stop"]) do
      {:ok, ""}               -> :ok
      {:error, {:status, 75}} -> {:error, :already_stopped}
      {:error, reason}        -> {:error, reason}
    end
  end

  @doc """
  Ensure that the dovecot server is configured and running.

  See `start/0`.
  """
  @spec ensure(Keyword.t) :: :ok | {:error, any}
  def ensure(opts \\ []) do
    if Dovetail.up? do
      :ok
    else
      {:ok, template_opts} = Dovetail.config(opts)
      case Dovetail.start() do
        :ok -> :ok
        {:error, :already_started} -> :ok
        {:error, _} = err -> err
      end
    end
  end

  @doc """
  Reload the configure by calling `doveadm reload`.
  """
  @spec reload :: :ok | {:error, any}
  def reload do
    case Process.doveadm(["reload"]) do
      {:ok, ""}         -> :ok
      {:error, _} = err -> err
    end
  end

  @doc """
  Create the dovecot server's configuration, reloading it if dovecot is
  running.
  """
  @spec config(Keyword.t) :: {:ok, Keyword.t} | {:error, any}
  def config(opts \\ []) do
    conf_path = Dict.get(opts, :target, Config.target_path())
    template_opts = opts
    |> Dict.take([:default_user, :log_path, :passdb_path])
    |> Config.template()
    |> Config.write!(conf_path)
    if up? do
      case reload() do
        :ok -> {:ok, template_opts}
        any -> any
      end
    else
      {:ok, template_opts}
    end
  end

  @doc """
  Get the user store.

  See `Dovetail.UserStore`.
  """
  @spec get_user_store :: {:ok, UserStore.t} | {:error, any}
  def get_user_store do
    {:ok, UserStore.PasswordFile.new!(@pass_db)}
  end

end
