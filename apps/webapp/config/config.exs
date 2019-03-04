# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :webapp,
  ecto_repos: [Webapp.Repo]

# Configures the endpoint
config :webapp, WebappWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Mr4z0zu5nweCzvs5wZBByBW4PVhc0ydJnCJQa+U53WOxek2JHo4goH4DJ/9Caecq",
  render_errors: [view: WebappWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Webapp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
