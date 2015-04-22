defmodule Integration.UserTest do
  use ExUnit.Case, async: false

  alias Dovetail.UserStore
  alias Dovetail.Process

  setup do
    Dovetail.start()
    :timer.sleep(3000)
    on_exit fn ->
      Dovetail.stop()
    end
    {:ok, user_store} = Dovetail.get_user_store()
    {:ok, [user_store: user_store]}
  end

  test "adding a user", %{user_store: user_store} do
    user = TestHelper.rand_user()
    assert {:ok, user_store} = Dovetail.UserStore.add(user_store, user)
    {:ok, _} = call_doveadm_user(user.username)
    assert {:ok, _user_store} =
      Dovetail.UserStore.remove(user_store, user.username)
  end

  defp call_doveadm_user(arg) do
    case Process.doveadm(["user", arg]) do
      {:ok, raw_user}  -> {:ok, raw_user}
      {:error, 67}     -> {:error, :no_user}
      {:error, reason} -> {:error, reason}
    end
  end

end
