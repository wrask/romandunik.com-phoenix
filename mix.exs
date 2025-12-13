defmodule Hello.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      build_path: "/mix/_build",
      deps_path: "/mix/deps",
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      releases: releases(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {Hello.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:bandit, "1.9.0"},
      {:credo, "1.7.14", only: [:dev, :test], runtime: false},
      {:earmark, "1.4.48"},
      {:ecto_sql, "3.13.3"},
      {:excoveralls, "0.18.5", only: [:dev, :test]},
      {:finch, "0.20.0"},
      {:floki, "0.38.0", only: :test},
      {:gettext, "1.0.2"},
      {:heroicons, "0.5.6"},
      {:jason, "1.4.4"},
      {:makeup, "~> 1.0"},
      {:makeup_elixir, "1.0.1"},
      {:nimble_publisher, "1.1.1"},
      {:phoenix, "1.8.3"},
      {:phoenix_ecto, "4.7.0"},
      {:phoenix_html, "4.3.0"},
      {:phoenix_live_dashboard, "0.8.7"},
      {:phoenix_live_reload, "1.6.2", only: :dev},
      {:phoenix_live_view, "1.1.19"},
      {:postgrex, "0.21.1"},
      {:telemetry_metrics, "1.1.0"},
      {:telemetry_poller, "1.3.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp releases do
    [
      hello: [
        include_executables_for: [:unix]
      ]
    ]
  end
end
