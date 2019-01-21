defmodule AdventureServer.Repo do
  use Ecto.Repo,
    otp_app: :adventure_server,
    adapter: Ecto.Adapters.Postgres
end
