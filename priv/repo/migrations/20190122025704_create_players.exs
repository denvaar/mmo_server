defmodule AdventureServer.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :info, :map

      timestamps()
    end

  end
end
