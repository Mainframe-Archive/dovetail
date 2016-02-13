defmodule Dovetail.Deliver do
  @moduledoc """
  Use dovecot's LDA [deliver] to deliver mail.
  """

  alias Dovetail.Config

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
  @spec call(String.t, String.t, Keyword.t) :: :ok | {:error, any}
  def call(username, email, options \\ [])
      when is_binary(username) and is_binary(email) and is_list(options) do
    exec_path = Keyword.get(options, :exec_path, @default_exec_path)
    args = ["-c", Config.conf_path(), "-e", "-d", username]
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
Date: <%= @date %>
Message-ID: <%= @message_id %>

<%= @body %>
"""

  EEx.function_from_string :def, :new_email, @email_template, [:assigns]

  def new_message_id do
    {:ok, host} = :inet.gethostname()
    "#{:erlang.unique_integer()}@#{host}.com"
  end

  # Private Functions

  defmodule DateTimeOffset do
    defstruct [:datetime, :offset]
    @type t :: %__MODULE__{datetime: :calendar.datetime, offset: integer}

    @spec now :: t
    def now do
      # For now, return universal time and an time zone adjust of 0
      %__MODULE__{datetime: :calendar.universal_time(),
                  offset: 0}
    end
  end

  @spec send_email(Port.t, String.t) :: Port.t
  defp send_email(port, email) do
    true = :erlang.port_command(port, email)
    port
  end

end

defimpl String.Chars, for: Dovetail.Deliver.DateTimeOffset do
  alias Dovetail.Deliver.DateTimeOffset

  def to_string(%DateTimeOffset{datetime: {{year, month, day} = date, time},
                                offset: 0}) do
    # Example: Wed Feb 10 11:23:57 2016
    join([:calendar.day_of_the_week(date) |> weekday_to_string(),
          month_to_string(month), int_to_string(day),
          time_to_string(time), Integer.to_string(year)], " ")
  end

  @weekdays ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  for {weekday, index} <- Enum.with_index(@weekdays) do
    defp weekday_to_string(unquote(index + 1)), do: unquote(weekday)
  end

  @months ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
           "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  for {month, index} <- Enum.with_index(@months) do
    defp month_to_string(unquote(index + 1)), do: unquote(month)
  end

  defp time_to_string({hours, minutes, seconds}) do
    join([int_to_string(hours),
          int_to_string(minutes),
          int_to_string(seconds)],
         ":")
  end

  @spec join([String.t], String.t) :: String.t
  defp join(strings, spacer) do
    join(Enum.reverse(strings), spacer, "")
  end

  defp join([], _spacer, acc), do: acc
  defp join([string], spacer, acc) do
    join([], spacer, string <> acc)
  end
  defp join([string | strings], spacer, acc) do
    join(strings, spacer, spacer <> string <> acc)
  end

  @spec int_to_string(integer, integer) :: String.t
  defp int_to_string(int, padding \\ 2) when is_integer(int) do
    Integer.to_string(int) |> String.rjust(padding, ?0)
  end


end
