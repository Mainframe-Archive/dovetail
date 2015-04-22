defmodule TestHelper do

  alias Dovetail.User

  @dir Application.app_dir(:dovetail, "test")

  # Public Functions

  @doc """
  Returns the path to the testing data directory.
  """
  @spec join_path(List.t | String.t) :: String.t
  def join_path(path) when is_binary(path), do: Path.join(@dir, path)
  def join_path(path) when is_list(path),   do: Path.join([@dir | path])


  @doc """
  Create a username from random data and defaults.
  """
  @spec rand_user :: User.t
  def rand_user, do: User.new(rand, rand)


  @doc """
  Create a random string of the provided length, from the list of chars
  provided. The default range of characters are lowercase alphabetic
  characters.

  NB: for a new sequence of random strings, `random_seed/0` must be called
  first
  """
  @default_range Enum.to_list(97..122) # Enum.to_list(65..90)
  def rand(length \\ 10, range \\ @default_range, acc \\ [])
  def rand(0, _, acc) do
    :erlang.list_to_binary(acc)
  end
  def rand(length, range, acc) do
    n = length(range) |> :random.uniform
    rand(length - 1, range, [Enum.at(range, n - 1) | acc])
  end

end

Dovetail.write_config()
ExUnit.configure(exclude: [pending: true])
ExUnit.start()
