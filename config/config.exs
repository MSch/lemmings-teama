# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lemmings,
  ecto_repos: [Lemmings.Repo]

# Configures the endpoint
config :lemmings, Lemmings.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pa8BT9UCfe9Hd8teceGAHmTqXKY3P+Br2xdGRF4e9v7Ofqno2xacMH6oYnY4lAug",
  render_errors: [view: Lemmings.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lemmings.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
