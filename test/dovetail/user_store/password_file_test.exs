defmodule Dovetail.UserStore.PasswordFileTest do
  use ExUnit.Case

  alias Dovetail.UserStore

  setup do
    store = ["passwd_files", TestHelper.rand <> ".passwd"]
    |> TestHelper.join_path
    |> UserStore.PasswordFile.new!

    on_exit fn ->
      File.rm!(store.path)
    end

    {:ok, [store: store]}
  end

  test "add/2", %{store: store} do
    assert {:ok, store} == UserStore.add(store, TestHelper.rand_user)
    assert lines(store) == 1
  end

  test "remove/2", %{store: store} do
    n = 5
    users = for _ <- 0..(n - 1), do: TestHelper.rand_user

    for {user, i} <- Stream.with_index(users) do
      {:ok, ^store} = UserStore.add(store, user)
      assert lines(store) == i + 1
    end

    for {user, i} <- Stream.with_index(users) do
      assert lines(store) == n - i
      {:ok, ^store} = UserStore.remove(store, user.username)
      assert lines(store) == n - i - 1
    end
  end

  # Private Functions

  defp lines(store) do
    case UserStore.PasswordFile.decode(store) do
      {:ok, results}    -> length(results)
      {:error, :enoent} -> 0
    end
  end

end
