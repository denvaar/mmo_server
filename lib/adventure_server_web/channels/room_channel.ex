defmodule AdventureServerWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", %{"client_id" => client_id}, socket) do
    send(self(), {:load_players, client_id})
    send(self(), {:spawn_player, client_id})

    {:ok, assign(socket, :player_id, client_id)}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(_reason, socket) do
    pid = AdventureServer.ActiveUser.pid_for_player_id(String.to_atom(socket.assigns.player_id))
    Phoenix.Tracker.untrack(AdventureServerWeb.PlayerTracker, pid, "active_players", socket.assigns.player_id)

    AdventureServer.ActiveUser.save_state(
      String.to_atom(socket.assigns.player_id)
    )
    broadcast_from!(
      socket,
      "player_left",
      %{"player_id" => socket.assigns.player_id}
    )
  end

  def handle_info({:load_players, client_id}, socket) do
    player_infos =
      Phoenix.Tracker.list(AdventureServerWeb.PlayerTracker, "active_players")
      |> Enum.map(fn ({id, _}) ->
        AdventureServer.ActiveUser.show_state(String.to_atom(id))
      end)

    for player_info <- player_infos do
      push(
        socket,
        "player_joined",
        player_info
      )
    end

    {:ok, pid} = AdventureServer.ActiveUser.start_link("#{client_id}")
    player_info = AdventureServer.ActiveUser.show_state(
      String.to_atom("#{client_id}")
    )

    Phoenix.Tracker.track(AdventureServerWeb.PlayerTracker, pid, "active_players", client_id, %{})

    broadcast_from!(
      socket,
      "player_joined",
      player_info
    )

    {:noreply, socket}
  end

  def handle_info({:spawn_player, client_id}, socket) do
    player_info = AdventureServer.ActiveUser.show_state(
      String.to_atom("#{client_id}")
    )

    push(socket, "spawn_player", player_info)

    {:noreply, socket}
  end

  def handle_in("player_moved", %{"path" => path, "player_id" => player_id} = data, socket) do
    %{"x" => x, "y" => y} =
      path
      |> List.last()

    "#{player_id}"
    |> String.to_atom()
    |> AdventureServer.ActiveUser.update_position(x, y)

    broadcast_from!(socket, "player_moved", data)
    {:noreply, socket}
  end
end
