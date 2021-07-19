# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :egggen_api, EgggenApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GsC7nkbDRz1/X0VATU/dGNsugbsjNsqzp2jFZkyrCniD75BwXrZX006eLuCPoTAC",
  render_errors: [view: EgggenApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: EgggenApi.PubSub,
  live_view: [signing_salt: "AxS3lEME"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
