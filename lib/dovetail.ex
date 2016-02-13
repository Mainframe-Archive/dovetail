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

      iex> Dovetail.set_config(); :ok
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

  alias Dovetail.{Process, UserStore, Config, User, Deliver}
  require Logger

  # TODO - this should be defined elsewhere
  @dovecot Application.app_dir(:dovetail, "priv/dovecot/sbin/dovecot")

  # await defaults
  @timeout 5000
  @interval 50
  @await_opts [timeout: @timeout, interval: @interval]

  # deliver defaults
  @from_default "sender@example.org"
  @subject_default "subj"
  @body_default "A body."


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
    case Process.dovecot() do
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
    Logger.info("Dovecot: stopping...")
    case Process.dovecot(["stop"]) do
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
      {:ok, template_opts} = Dovetail.set_config(opts)
      case Dovetail.start() do
        :ok -> :ok
        {:error, :already_started} -> :ok
        {:error, _} = err -> err
      end
    end
  end


  @doc """
  Deliver the email to user.

  ## Options

    * `:from :: String.t` default #{inspect @from_default}
    * `:subject :: String.t` default #{inspect @subject_default}
    * `:body :: String.t` default #{inspect @body_default}
    * `:exec_path :: String.t` the path to the deliver executable
  """
  @spec deliver(User.t | String.t, Keyword.t) :: :ok | {:error, any}
  def deliver(user, opts \\ [])
  def deliver(%User{username: username}, opts) do
    deliver(username, opts)
  end
  def deliver(username, opts) when is_binary(username) do
    email_opts = [from: @from_default,
                  subject: @subject_default,
                  body: @body_default,
                  date: Deliver.DateTimeOffset.now(),
                  message_id: Deliver.new_message_id()]
      |> Dict.merge(Dict.take(opts, [:from, :subject, :body]))
      |> Dict.put(:to, username)
    deliver_opts = Dict.take(opts, [:exec_path])
    email = Deliver.new_email(email_opts)
    case Deliver.call(username, email, deliver_opts) do
      :ok -> {:ok, email}
      {:error, _} = err -> err
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
  @spec set_config(Keyword.t) :: {:ok, Keyword.t} | {:error, any}
  def set_config(opts \\ []) do
    conf_path = Dict.get(opts, :target, Config.conf_path())
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
  Get all of the active dovecot variables as a keyword list.
  """
  @spec get_config :: {:ok, Keyword.t} | {:error, any}
  def get_config() do
    case Process.dovecot(["config"]) do
      {:ok, encoded} -> parse_config(encoded)
      {:error, {:status, 75}} -> {:error, :already_stopped}
      {:error, _} = err -> err
    end
  end

  @doc """
  Get the active dovecot config value for the given variable.
  """
  @spec get_config(String.t | Atom.t, any) :: {:ok, any} | {:error, any}
  def get_config(var, default \\ nil)
  def get_config(var, default) when is_atom(var) do
    get_config(Atom.to_string(var), default)
  end
  def get_config(var, default) do
    case Process.dovecot(["config"]) do
      {:ok, encoded} ->
        case parse_config(encoded) do
          {:ok, config} ->
            case Dict.fetch(config, var) do
              {:ok, nil} -> {:ok, default}
              {:ok, value} -> {:ok, value}
              :error -> {:ok, default}
            end
          {:error, _} = err -> err
        end
      {:error, {:status, 75}} -> {:error, :already_stopped}
      {:error, _} = err -> err
    end
  end

  @doc """
  Get the user store.

  See `Dovetail.UserStore`.
  """
  @spec get_user_store :: {:ok, UserStore.t} | {:error, any}
  def get_user_store do
    {:ok, UserStore.PasswordFile.new!(Config.passdb_path)}
  end

  ## Private Functions

  defp parse_config(string) when is_binary(string) do
    String.split(string, "\n") |> parse_config()
  end
  defp parse_config(lines), do: parse_config(lines, [])

  defp parse_config([], acc), do: {:ok, Enum.into(acc, HashDict.new())}
  defp parse_config([<<?#, _ :: binary>> | lines], acc) do
    parse_config(lines, acc)
  end
  defp parse_config([line | lines], acc) do
    # NB: this doesn't handle quoted strings, e.g `a = " = "`
    case String.split(line, " = ") do
      [name, ""] ->
        parse_config(lines, [{name, nil} | acc])
      [name, value] ->
        parse_config(lines, [{name, value} | acc])
      _ ->
        # NB: this is an ugly throwaway
        parse_config(lines, acc)
    end
  end
end
