defmodule AdventureServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      AdventureServer.Repo,
      # Start the endpoint when the application starts
      AdventureServerWeb.Endpoint,
      AdventureServerWeb.Presence
      # Starts a worker by calling: AdventureServer.Worker.start_link(arg)
      # {AdventureServer.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AdventureServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AdventureServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
