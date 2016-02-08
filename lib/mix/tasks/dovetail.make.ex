defmodule Mix.Tasks.Dovetail.Make do
  @moduledoc """
  Mix task to make the dovecot server.
  """

  def run(_args) do
    case Mix.Shell.IO.cmd("make") do
      0 ->
        Mix.Shell.IO.info("make success.")
      status ->
        Mix.Shell.IO.error("make status code: #{inspect status}")
    end
  end
end
