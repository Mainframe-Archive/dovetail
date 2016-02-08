defmodule Dovetail.Watcher do
  @moduledoc """
  This module implements a worker process for starting, monitoring,
  and stopping a dovecot server.

  TODO: notification (poll?) if dovecot dies
  """
  use GenServer

  @supervisor_name __MODULE__

  ## Public Functions

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil,
                         Dict.put_new(opts, :name, @supervisor_name))
  end

  ## Server Callbacks

  def init(nil) do
    :ok = Dovetail.ensure()
    {:ok, %{}}
  end

  def terminate(_reason, _state) do
    :ok = Dovetail.stop()
  end

end
