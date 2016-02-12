defmodule Mix.Tasks.Dovetail.Config do
  @moduledoc """
  Mix task to template out the dovecot config file.
  """

  # Mix Callbacks

  def run(args) do
    case OptionParser.parse(args) do
      {options, [], []} ->
        {:ok, template_options} = Dovetail.set_config(options)
        Mix.Shell.IO.info(
          "Templated dovecot.conf with #{inspect(template_options)}")
      {_, argv, []} ->
        # TODO - exit with error status
        Mix.Shell.IO.error("unexpected argv: #{inspect argv}")
      {_, _, error} ->
        # TODO - exit with error status
        Mix.Shell.IO.error("bad args: #{inspect error}")
    end
  end

end
