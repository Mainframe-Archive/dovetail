defmodule Dovetail.Deliver do
  @moduledoc """
  Use dovecot's LDA [deliver] to deliver mail.
  """

  alias Dovetail.Config
  alias Dovetail.User

  require Logger
  require EEx

  @timeout 5000
  @default_exec_path Path.join(Config.dovecot_path(),
                               "libexec/dovecot/deliver")

  @doc """
  Deliver the email to the dovecot user.

  ## Options

   * `:exec_path :: String.t` the path to the deliver executable.
  """
  @spec call(User.t, String.t, Keyword.t) :: :ok | {:error, any}
  def call(%User{} = user, email, options \\ [])
      when is_binary(email) and is_list(options) do
    exec_path = Keyword.get(options, :exec_path, @default_exec_path)
    args = ["-c", Config.target_path(), "-e", "-d", user.username]
    true = :erlang.open_port({:spawn_executable, exec_path},
                      [:use_stdio | [args: args]])
      |> send_email(email)
      |> :erlang.port_close()
    :ok
  end


  # Date: Fri, 21 Nov 1997 09:55:06 -0600
  @email_template """
From: <%= @from %>
To: <%= @to %>
Subject: <%= @subject %>

<%= @body %>
"""

  EEx.function_from_string :def, :new_email, @email_template, [:assigns]

  # Private Functions

  defp send_email(port, email) do
    true = :erlang.port_command(port, email)
    port
  end

end
