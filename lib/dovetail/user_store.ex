defprotocol Dovetail.UserStore do
  @moduledoc """
  The `Dovetial.UserStore` module defines the users store protocol.
  """
  alias Dovetail.User

  # Type Specs

  @type t :: map

  # Protocol Functions

  @doc """
  Add `user` to `store`.
  """
  @spec add(t, User.t) :: {:ok, t} | {:error, term}
  def add(store, user)

  @doc """
  Remove `user` from `store`.
  """
  @spec remove(t, User.username) :: {:ok, t} | {:error, term}
  def remove(store, username)

end
