defmodule Dovetail.Supervisor do
  @moduledoc """
  The top level supervisor for the `:dovetail` application.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    children = [worker(Dovetail.Watcher, [])]
    supervise(children, strategy: :one_for_all)
  end
end
