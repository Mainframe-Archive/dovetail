defmodule Dovetail.User do
  @moduledoc """
  The `Dovetail.User` module provides a user struct.
  """

  defstruct [:username, :passtype, :password, :uid, :gid, :home]

  @default_password "password"

  # Type Specs

  @type username :: String.t
  @type passtype :: :plain | :crypt
  @type password :: String.t
  @type uid      :: Integer.t
  @type gid      :: Integer.t
  @type home     :: String.t

  @type t :: %__MODULE__{
    username: username,
    passtype: passtype,
    password: password,
    uid:      uid,
    gid:      gid,
    home:     home}

  # Public Functions

  @doc """
  Create a new user struct.
  """
  def new(username, password \\ {:plain, @default_password}, opts \\ [])
  def new(username, password, opts) when is_binary(password) do
    new(username, {:plain, password}, opts)
  end
  def new(username, {passtype, password}, opts) do
    %__MODULE__{
      username: username,
      passtype: passtype,
      password: password,
      uid:      opts[:uid],
      gid:      opts[:gid],
      home:     opts[:home]}
  end

end
