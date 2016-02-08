defmodule DovetailTest do
  use ExUnit.Case
  # doctest Dovetail

  test "up?/0" do
    assert Dovetail.up?
  end

  test "Dovetail.start/0 already started" do
    assert {:error, :already_started} == Dovetail.start()
  end

  test "Dovetail.ensure/0" do
    assert :ok == Dovetail.ensure()
  end

end
