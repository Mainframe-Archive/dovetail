defmodule Dovetail.DeliverTest do
  use ExUnit.Case, async: false

  alias Dovetail.{Deliver, UserStore}
  alias Dovetail.Deliver.DateTimeOffset

  setup do
    user = TestHelper.rand_user()
    {:ok, user_store} = Dovetail.get_user_store()
    {:ok, user_store} = Dovetail.UserStore.add(user_store, user)

    on_exit fn ->
      {:ok, _} = UserStore.remove(user_store, user.username)
    end

    {:ok, [user: user]}
  end

  test "delivering mail to an existing user", %{user: user} do
    email = Deliver.new_email(to: "#{user.username}@example.com",
                              from: "john@doe.com",
                              subject: "subjective",
                              body: "content",
                              date: DateTimeOffset.now())
    assert :ok == Deliver.call(user.username, email)
  end

  test "DateTimeOffset.now/0" do
    dto = DateTimeOffset.now()
    {date, time} = dto.datetime
    assert is_tuple(date)
    assert is_tuple(time)
    assert 0 == dto.offset
  end

  test "inspect(%DateTimeOffset{})" do
    dto = DateTimeOffset.now()
    assert is_binary(inspect(dto))
  end

end
