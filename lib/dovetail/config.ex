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

  TODO: allow the dovecot root to be set with an option.
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
  def write!({template, options}, path \\ conf_path()) do
    Path.dirname(path) |> File.mkdir_p!()
    File.write!(path, template)
    options
  end

  @doc """
  Return the path to the dovecot configuration file, `dovecot.conf`.
  """
  @spec conf_path :: String.t
  def conf_path do
    Application.app_dir(:dovetail,  "dovecot.conf")
  end

  @doc """
  Return the path to the dovecot base run directory. State files will be
  kept relative to this directory.
  """
  @spec base_path :: String.t
  def base_path do
    Application.app_dir(:dovetail, Path.join("var", "dovecot"))
  end

  @doc """
  Return the path to dovecot.
  """
  @spec dovecot_path :: String.t
  def dovecot_path do
    Application.app_dir(:dovetail, Path.join("priv", "dovecot"))
  end

  @doc """
  Return the path to the passdb.

  Currently only intended for passdb-file.
  """
  @spec passdb_path :: String.t
  def passdb_path do
    Path.join([Application.app_dir(:dovetail), "var", "pass.db"])
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
    # NB: this has the side effect of creating the necessary directories
    %{default_user:       whoami!(),
      mail_location_path: mail_location_path() |> ensure_path(),
      log_path:           log_path() |> ensure_path(),
      passdb_path:        passdb_path() |> ensure_path(),
      base_path:          base_path() |> ensure_path()
     }
  end

  @spec mail_location_path :: String.t
  defp mail_location_path do
    Path.join([Application.app_dir(:dovetail), "var", "Maildir"])
  end

  @spec log_path :: String.t
  defp log_path do
    Path.join([Application.app_dir(:dovetail), "var", "dovecot.log"])
  end

  @spec whoami! :: String.t
  defp whoami! do
    case System.cmd("whoami", []) do
      {username, 0} -> String.strip(username)
      {_, code}     -> raise ArgumentError, message: "bad whoami: #{code}"
    end
  end

  defp ensure_path(path) do
    :ok = Path.dirname(path) |> File.mkdir_p!()
    path
  end

end
