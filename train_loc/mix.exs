defmodule Trainloc.Mixfile do
  use Mix.Project

  def project do
    [app: :trainloc,
     version: "0.1.0",
     elixir: "~> 1.5.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [
        :logger,
        :timex,
        :logger_logentries_backend
        ],
    mod: {TrainLoc, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
        {:timex, "~> 3.1.24"},
        {:ehmon, git: "https://github.com/heroku/ehmon.git", tag: "v4"},
        {:logger_logentries_backend, github: "paulswartz/logger_logentries_backend"}
    ]
  end
end
