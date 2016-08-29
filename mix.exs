defmodule Brainfark.Mixfile do
  use Mix.Project

  def project do
    [app: :brainfark,
     version: "0.5.0",
     elixir: "~> 1.3",
     name: "Brainfark",
     source_url: "https://github.com/bbugh/brainfark",
     homepage_url: "https://github.com/bbugh/brainfark",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Brainfark],
     docs: [extras: docs()],
     deps: deps(),
     default_task: "test",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp docs do
    ["README.md": [title: "Readme"]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_guard, "~> 1.1.1", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
      {:credo, "~> 0.4", only: :dev},
      {:ex_doc, "~> 0.12", only: :dev},
      {:zipper_list, github: "bbugh/zipper_list"}
    ]
  end
end
