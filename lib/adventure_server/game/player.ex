defmodule AdventureServer.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset


  schema "players" do
    field :info, :map

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:info])
    |> validate_required([:info])
  end
end
