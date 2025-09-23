defmodule MDExMermaid.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/mdex_mermaid"
  @version "0.3.1-dev"

  def project do
    [
      app: :mdex_mermaid,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      name: "MDExMermaid",
      source_url: @source_url,
      description: "MDEx plugin for Mermaid"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        docs: :docs,
        "hex.publish": :docs
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Leandro Pereira"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/mdex_mermaid/changelog.html",
        GitHub: @source_url
      },
      files: [
        "mix.exs",
        "lib",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ]
    ]
  end

  defp docs do
    [
      main: "MDExMermaid",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["CHANGELOG.md"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp deps do
    [
      {:mdex, "~> 0.9"},
      {:ex_doc, ">= 0.0.0", only: :docs},
      {:makeup_elixir, "~> 1.0", only: :docs},
      {:makeup_eex, "~> 2.0", only: :docs},
      {:makeup_syntect, "~> 0.1", only: :docs}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "compile"]
    ]
  end
end
