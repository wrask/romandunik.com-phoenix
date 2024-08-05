# This file is responsible for configuring your application and its
# dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :hello,
  ecto_repos: [Hello.Repo],
  generators: [timestamp_type: :utc_datetime]

config :hello, HelloWeb.Endpoint,
  # Enable both ipv4 and ipv6 on all interfaces. By the way, the port is
  # configured with an environment variable and it's in the runtime.exs config.
  http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HelloWeb.ErrorHTML, json: HelloWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Hello.PubSub,
  live_view: [signing_salt: "aC4Hk8o2"],
  owner_site_url: "https://romandunik.com",
  repository_url: "https://github.com/wrask/phoenix-dockerized"

config :hello, Hello.Repo, adapter: Ecto.Adapters.Postgres

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :hello, Hello.Mailer, adapter: Swoosh.Adapters.Local

config :swoosh, :api_client, false

import_config "#{Mix.env()}.exs"
