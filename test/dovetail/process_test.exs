defmodule Dovetail.ProcessTest do
  use ExUnit.Case

  alias Dovetail.Process

  test "doveadm/1" do
    assert :ok == Process.doveadm(["start"])
    {:ok, path} = which("doveadm")
    assert path
  end

  @spec which(String.t) :: {:ok, String.t} | {:error, :not_found}
  defp which(command) when is_binary(command) do
    case System.cmd("which", [command]) do
      {path, 0} -> String.strip(path)
      {"",   1} -> {:error, :not_found}
    end
  end

end
