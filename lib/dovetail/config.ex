defmodule Dovetail.Config do
  @moduledoc """
  The `Dovetail.Config` module provides functions for templating in a
  `dovetail.conf` file.

  ## Example

  """
  require EEx

  # Setup Templating

  @dovetail_conf_template Application.app_dir(
    :dovetail, "priv/dovecot.conf.eex")

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
  def write!({template, options}, path \\ dovecot_conf_target()) do
    Path.dirname(path) |> File.mkdir_p!()
    File.write!(path, template)
    options
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
    %{default_user: "dovetail",
      log_path:     log_path(),
      passdb_path:  passdb_path()}
  end

  @spec passdb_path :: String.t
  defp passdb_path do
    Path.join(Application.app_dir(:dovetail), "pass.db")
  end

  @spec log_path :: String.t
  defp log_path do
    Path.join(Application.app_dir(:dovetail), "log")
  end

  @spec dovecot_conf_target :: String.t
  defp dovecot_conf_target do
    Path.join(dovecot_path(), "etc/dovecot/dovecot.conf")
  end

  @spec dovecot_path :: String.t
  defp dovecot_path do
    Application.get_env(:dovetail, :dovecot_path,
                        Application.app_dir(:dovetail, "priv/dovecot"))
  end

end
