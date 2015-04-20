defmodule Dovetail.Process do
  @moduledoc """
  The `Dovetail.Dovecot` module provides functions for managing
  the dovecot process.

  This module requires Dovetail's rootless Dovecot install. See
  `Dovecot`.

  ## Examples

      iex> Process.up?
      false
      iex> Process.start()
      :ok
      iex> Process.up?
      true
      iex> Process.stop()
      :ok
      iex> Process.up?
      false
  """

  # Module Attributes

  @dovecot Application.app_dir(:dovetail, "priv/dovecot/sbin/dovecot")
  @doveadm Application.app_dir(:dovetail, "priv/dovecot/bin/doveadm")

  # Type Specs

  @type doveadm_opts :: [doveadm: String.t]

  # Public Functions

  @doc """
  Check if dovecot is up.
  """
  def up?(options \\ []) do
    case pgrep(["-f", Keyword.get(options, :path, @dovecot)]) do
      {:ok, _}    -> true
      {:error, _} -> false
    end
  end

  @doc """
  Start the dovecot server with the default settings.

  See `dovecot/0`.
  """
  def start do
    case dovecot() do
      {:ok, ""}               -> :ok
      {:error, {:status, 89}} -> {:error, :already_started}
      {:error, reason}        -> {:error, reason}
    end
  end

  @doc """
  Start the dovecot server with the default settings.

  See `doveadm(["stop"])`
  """
  def stop do
    case doveadm(["stop"]) do
      {:ok, ""}               -> :ok
      {:error, {:status, 75}} -> {:error, :already_stopped}
      {:error, reason}        -> {:error, reason}
    end
  end

  @doc """
  Call the dovecot executable with options.

  * `path` the dovecot name or path. Defaults to #{inspect(@dovecot)}.
  """
  def dovecot(args \\ [], opts \\ []) do
    Keyword.get(opts, :path, @dovecot) |> cmd(args)
  end

  @doc """
  Call the doveadm executable with `args`.

  ## Options

    * `path` the doveadm name or path. Defaults to #{inspect(@doveadm)}.
  """
  @spec doveadm([String.t], doveadm_opts) ::
    {:ok, String.t} | {:error, :bad_args | :unknown}
  def doveadm(args, opts \\ []) do
    Keyword.get(opts, :path, @doveadm) |> cmd(args)
  end

  # Private Functions

  @spec cmd(String.t, [String.t]) ::
    {:ok, String.t} | {:error, :bad_args | :unknown}
  defp cmd(command, args) do
    case System.cmd(command, args) do
      {out, 0}    -> {:ok, out}
      {_, 64}     -> {:error, :bad_args}
      {_, status} -> {:error, {:status, status}}
    end
  end


  defp pgrep(args) do
    case System.cmd("pgrep", args, [stderr_to_stdout: true]) do
      {result, 0} -> {:ok, String.strip(result) |> String.to_integer()}
      {_, status} -> {:error, {:status, status}}
    end
  end
end
