defmodule Dovetail.UserStore.PasswordFile do
  @moduledoc """
  The `Dovetail.Usertore.PasswordFile` module provides a handler and
  functions for interacting with a dovecot password file.
  """
  alias Dovetail.UserStore.PasswordFile
  alias Dovetail.User

  # Module Attributes

  defstruct [:path]

  @line_re ~r/^(?<username>.*):{(?<passtype>.*)}(?<password>.*):(?<uid>.*):(?<gid>.*):(?<home>.*):(?<extra_fields>.*)$/

  # Type Specs

  @type t       :: %__MODULE__{path: String.t}

  # Public Functions

  @doc """
  Returns a new password file handler for `path`.
  """
  @spec new!(String.t) :: t
  def new!(path), do: %__MODULE__{path: path}

  @doc """
  Decode the string or password file struct to a list of users. If attempting
  to decode a non-existent file, it will return an `:ok` tuple wrapping an
  empty list of users.
  """
  @spec decode(String.t | t) :: {:ok, [User.t]} | {:error, term}
  def decode(%__MODULE__{path: path}) do
    case File.read(path) do
      {:ok, string}     -> decode(string)
      {:error, :enoent} -> {:ok, []}
      {:error, reason}  -> {:error, reason}
    end
  end

  def decode(string) when is_binary(string) do
    {:ok, (for l <- String.split(string, "\n", trim: true), do: decode_line(l))}
  end

  @doc """
  Encode `users` into an iolist.
  """
  # TODO - error condition
  @spec encode([User.t]) :: {:ok, iolist}
  def encode(users) do
    {:ok, (for user <- users, do: encode_user(user))}
  end

  @doc """
  Append the `user` to `store`. If a user with username already exists
  in the store, that users's info will be replaced with the new user info.

  This function doesn't support concurrent use for a common store path.
  """
  @spec add(t, User.username) :: {:ok, t} | {:error, term}
  def add(store, user) do
    # XXX -- read/write race condition if used concurrently
    case decode(store) do
      {:ok, users} ->
        users = [user | filter_out_username(users, user.username)]
        write(store, users)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Remove users with `username` from `store`.
  """
  @spec remove(t, User.username) :: {:ok, t} | {:error, term}
  def remove(store, username) do
    case decode(store) do
      {:ok, users} ->
        users = filter_out_username(users, username)
        write(store, users)
      {:error, reason} -> {:error, reason}
    end
  end

  # Private Functions

  @spec decode_line(String.t) :: {:ok, User.t} | {:error, :bad_string}
  defp decode_line(string) do
    case Regex.named_captures(@line_re, string) do
      %{"username" => username,
        "password" => password,
        "passtype" => passtype,
        "uid"      => uid,
        "gid"      => gid,
        "home"     => home} ->
        User.new(username, {String.to_existing_atom(passtype), password},
                 uid: uid, gid: gid, home: home)
      _ -> {:error, :bad_string}
    end
  end

  @spec encode_user(User.t) :: String.t
  def encode_user(%User{username: username,
                        password: password,
                        passtype: passtype,
                        uid:      uid,
                        gid:      gid,
                        home:     home}) do
    "#{username}:{#{passtype}}#{password}:#{uid}:#{gid}:#{home}:\n"
  end

  @spec write(t, [User.t]) :: :ok | {:error, term}
  defp write(store, users) do
    # Create the path to the store if necessary
    Path.dirname(store.path) |> File.mkdir_p()
    # Write users to store, replacing the existing file.
    case encode(users) do
      {:ok, string} ->
        case File.write(store.path, string) do
          :ok ->              {:ok, store}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  @spec filter_out_username([User.t], User.username) :: [User.t]
  defp filter_out_username(users, username) do
    Enum.filter(users, &(&1.username != username))
  end

end

defimpl Dovetail.UserStore, for: Dovetail.UserStore.PasswordFile do
  alias Dovetail.UserStore.PasswordFile

  def add(store, user), do: PasswordFile.add(store, user)
  def remove(store, username), do: PasswordFile.remove(store, username)
end
