defmodule Dovetail.Process do
  @moduledoc """
  The `Dovetail.Dovecot` module provides functions for calling
  dovecot binaries.

  See `dovecot/2` and `dove_adm/2`.
  """

  alias Dovetail.Config

  # Module Attributes

  @dovecot Application.app_dir(:dovetail, "priv/dovecot/sbin/dovecot")
  @doveadm Application.app_dir(:dovetail, "priv/dovecot/bin/doveadm")

  # Type Specs

  @type doveadm_opts :: [doveadm: String.t]

  # Public Functions

  @doc """
  Call the dovecot executable with options.

   * `:path` the dovecot name or path. Defaults to #{inspect(@dovecot)}.
   * `:config` the path to the dovecot config. This will be excluded if set
     to nil. Defaults to `#{inspect(Config.conf_path())}`.
  """
  def dovecot(args \\ [], opts \\ []) do
    args = case Dict.fetch(opts, :config) do
             :error -> ["-c", Config.conf_path() | args]
             {:ok, nil} -> args
             {:ok, path} -> ["-c", path | args]
           end
    Keyword.get(opts, :path, @dovecot) |> cmd(args)
  end

  @doc """
  Call the doveadm executable with `args`.

  ## Options

    * `:path` the doveadm name or path. Defaults to #{inspect(@doveadm)}.
  """
  @spec doveadm([String.t], doveadm_opts) ::
    {:ok, String.t} | {:error, any}
  def doveadm(args, opts \\ []) do
    Keyword.get(opts, :path, @doveadm) |> cmd(args)
  end

  @doc """
  Call pgrep with args, and parse result.
  """
  @spec pgrep([String.t]) :: {:ok, } | {:error, any}
  def pgrep(args) do
    case System.cmd("pgrep", args, [stderr_to_stdout: true]) do
      {result, 0} -> {:ok, String.strip(result) |> String.to_integer()}
      {_, status} -> {:error, {:status, status}}
    end
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

end
