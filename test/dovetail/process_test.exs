defmodule Dovetail.ProcessTest do
  use ExUnit.Case, async: false

  alias Dovetail.Process

  doctest Dovetail.Process

  setup do
    stop_if_up()
    on_exit &stop_if_up/0
  end

  test "up?/{0,1} and start/stop" do
    assert not Process.up?

    assert :ok == Process.start()
    assert {:error, :already_started} == Process.start()
    assert Process.up?

    assert :ok == Process.stop()
    assert {:error, :already_stopped} == Process.stop()
    assert not Process.up?
  end

  # Private Functions

  defp stop_if_up do
    if Process.up? do
      :ok = Process.stop()
    end
  end

end
