defmodule Dovetail.Mixfile do
  use Mix.Project

  def project do
    [app: :dovetail,
     version: "0.0.2",
     name: "Dovetail",
     description: description,
     source_url: "https://github.com/thusfresh/dovetail",
     elixir: "~> 1.2",
     deps: deps,
     package: package,
     docs: [extras: ["README.md"]]]
  end

  def application do
    [applications: [:logger],
     mod: {Dovetail, []}]
  end

  defp description do
    """
    Dovetail provides a harness for running test dovecot servers.
    """
  end

  defp package do
    [files: ["lib", "Makefile", "priv/dovecot.conf.eex",
             "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Thomas Moulia"],
     licenses: ["BSD 3-Clause"],
     links: %{"Github": "https://github.com/thusfresh/dovetail"}]
  end

  defp deps do
    [{:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

end
