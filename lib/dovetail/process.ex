defmodule Dovetail.Process do
  @moduledoc """
  The `Dovetail.Dovecot` module provides functions for managing
  the dovecot process.
  """

  # Module Attributes

  @doveadm "doveadm"

  # Type Specs

  @type doveadm_opts :: [doveadm: String.t]

  # Public Functions

  @doc """
  Call the doveadm executable with `args`.

  ## Options

    * `path` the doveadm name or path. Defaults to #{inspect(@doveadm)}.
  """
  @spec doveadm([String.t], doveadm_opts) ::
    {:ok, String.t} | {:error, :bad_args | :unknown}
  def doveadm(args, opts \\ []) do
    case Keyword.get(opts, :path, @doveadm) |> System.cmd(args) do
      {out, 0} -> {:ok, out}
      {_, 64}  -> {:error, :bad_args}
      {_, _}   -> {:error, :unknown}
    end
  end

end
