defmodule Dovetail.Mixfile do
  use Mix.Project

  def project do
    [app: :dovetail,
     version: "0.0.1",
     name: "Dovetail",
     source_url: "https://github.com/thusfresh/dovetail",
     elixir: "~> 1.2",
     deps: []]
  end

  def application do
    [applications: [:logger],
     mod: {Dovetail, []}]
  end

end
