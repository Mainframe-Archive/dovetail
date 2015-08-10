defmodule Dovetail.Config do
  @moduledoc """
  The `Dovetail.Config` module provides functions for templating in a
  `dovetail.conf` file.

  ## Mix Usage

      $ mix dovetail.config --default-user jtmoulia
  """
  require EEx

  # Module Attributes
  @dovetail_conf_template Application.app_dir(
    :dovetail, "priv/dovecot.conf.eex")

  # Setup Templating


  EEx.function_from_file :defp, :template_helper,
                         @dovetail_conf_template, [:assigns]

  # Public Functions

  @doc """
  Template out the config file.

  TODO: allow the dovecot root to be set with an
  """
  @spec template(Keyword.t) :: {String.t, Keyword.t}
  def template(options \\ []) when is_list(options) do
    overlayed = overlay(options)
    {template_helper(overlayed), overlayed}
  end

  @doc """

  Write the result of `template/1` to `path`, creating the path's directory
  prefix if it doesn't exist.

  Returns `options`.
  """
  @spec write!({String.t, Keyword.t}, String.t) :: Keyword.t
  def write!({template, options}, path \\ target_path()) do
    Path.dirname(path) |> File.mkdir_p!()
    File.write!(path, template)
    options
  end

  @doc """
  Return the target path for the dovecot configuration.
  """
  @spec target_path :: String.t
  def target_path do
    Application.app_dir(:dovetail,  "dovecot.conf")
  end

  @doc """
  Return the path to dovecot.
  """
  @spec dovecot_path :: String.t
  def dovecot_path do
    Application.app_dir(:dovetail, Path.join("priv", "dovecot"))
  end

  # Private Functions

  @spec overlay(Keyword.t) :: Keyword.t
  defp overlay(options) when is_list(options) do
    for {option, default} <- defaults() do
      {option, Keyword.get(options, option, default)}
    end
  end

  @spec defaults :: Keyword.t
  defp defaults do
    %{default_user:       whoami!(),
      mail_location_path: mail_location_path(),
      log_path:           log_path(),
      passdb_path:        passdb_path(),
      userdb_socket:      userdb_socket(),
      master_socket:      master_socket()
     }
  end

  @spec mail_location_path :: String.t
  defp mail_location_path do
    Path.join(Application.app_dir(:dovetail), "Maildir")
  end

  @spec passdb_path :: String.t
  defp passdb_path do
    Path.join(Application.app_dir(:dovetail), "pass.db")
  end

  @spec log_path :: String.t
  defp log_path do
    Path.join(Application.app_dir(:dovetail), "dovecot.log")
  end

  @spec userdb_socket :: String.t
  def userdb_socket do
    Path.join(Application.app_dir(:dovetail), "auth-userdb")
  end

  @spec master_socket :: String.t
  def master_socket do
    Path.join(Application.app_dir(:dovetail), "auth-master")
  end

  @spec whoami! :: String.t
  defp whoami! do
    case System.cmd("whoami", []) do
      {username, 0} -> String.strip(username)
      {_, code}     -> raise ArgumentError, message: "bad whoami: #{code}"
    end
  end

end
