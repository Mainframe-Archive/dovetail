defmodule DovetailTest do
  use ExUnit.Case, async: false

  # doctest Dovetail

  setup do
    stop_if_up()
    on_exit &stop_if_up/0
  end

  @tag pending: true
  test "up?/{0,1} and start/stop" do
    assert not Dovetail.up?

    assert :ok == Dovetail.start()
    assert {:error, :already_started} == Dovetail.start()
    assert Dovetail.up?

    assert :ok == Dovetail.stop()
    assert {:error, :already_stopped} == Dovetail.stop()
    assert not Dovetail.up?
  end

  # Private Functions

  defp stop_if_up do
    if Dovetail.up? do
      :ok = Dovetail.stop()
    end
  end

end
