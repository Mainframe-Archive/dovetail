defmodule Dovetail.DeliverTest do
  use ExUnit.Case, async: false

  alias Dovetail.Deliver
  alias Dovetail.UserStore

  setup do
    :ok = Dovetail.start()
    user = TestHelper.rand_user()
    {:ok, user_store} = Dovetail.get_user_store()
    {:ok, user_store} = Dovetail.UserStore.add(user_store, user)

    on_exit fn ->
      {:ok, _} = UserStore.remove(user_store, user.username)
      :ok = Dovetail.stop()
    end

    {:ok, [user: user]}
  end

  test "delivering mail to an existing user", %{user: user} do
    email = Deliver.new_email(to: "#{user.username}@example.com",
                              from: "john@doe.com",
                              subject: "subjective",
                              body: "content")
    assert :ok == Deliver.call(user, email)
  end

end
