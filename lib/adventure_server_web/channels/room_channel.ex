defmodule AdventureServerWeb.RoomChannel do
  use Phoenix.Channel
  alias AdventureServerWeb.Presence

  def join("room:lobby", %{"client_id" => client_id}, socket) do
    send(self(), {:after_join, client_id})

    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, client_id}, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, "player:#{client_id}", %{
      id: client_id,
      x: Enum.random(50..300),
      y: Enum.random(50..300)
    })

    {:noreply, socket}
  end

  def handle_in("player:move", data, socket) do
    broadcast_from!(socket, "player_moved", data)
    {:noreply, socket}
  end
end
