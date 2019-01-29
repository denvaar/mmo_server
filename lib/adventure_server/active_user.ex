defmodule AdventureServer.ActiveUser do
  use GenServer

  # Client API

  def start_link(player_id) do
    GenServer.start_link(
      __MODULE__,
      {:ok, player_id},
      [name: String.to_atom("#{player_id}")]
    )
  end

  def pid_for_player_id(player_id), do: GenServer.call(player_id, {:pid})

  def update_position(pid, x, y) do
    GenServer.call(pid, {:update_position, x, y})
  end

  def show_state(pid) do
    GenServer.call(pid, {:show_state})
  end

  def save_state(pid) do
    GenServer.call(pid, {:save_state})
  end

  # Server

  @impl true
  def init({:ok, player_id}) do
    player_info = fetch_player_info(player_id)
    schedule_next_job(:persist)

    {:ok, player_info}
  end

  @impl true
  def handle_info(:persist, player_info) do
    player_info
    |> save_player_state()

    schedule_next_job(:persist)

    {:noreply, player_info}
  end

  @impl true
  def handle_call({:show_state}, _from, player_info) do
    {:reply, player_info, player_info}
  end

  def handle_call({:save_state}, _from, player_info) do
    player_info
    |> save_player_state()

    {:reply, player_info, player_info}
  end

  def handle_call({:update_position, x, y}, _from, player_info) do
    new_player_info =
      %{player_info | "x" => x, "y" => y}

    {:reply, new_player_info, new_player_info}
  end

  def handle_call({:pid}, _from, player_info), do: {:reply, self(), player_info}

  @impl true
  def terminate(_reason, player_info) do
    player_info
    |> save_player_state()
  end

  defp save_player_state(player_info) do
    %AdventureServer.Game.Player{id: Map.get(player_info, "id")}
    |> AdventureServer.Game.Player.changeset(%{info: player_info})
    |> AdventureServer.Repo.update!()
  end

  defp fetch_player_info(player_id) do
    AdventureServer.Repo.get!(AdventureServer.Game.Player, player_id)
    |> Map.take([:info])
    |> Kernel.get_in([:info])
  end

  defp schedule_next_job(:persist = action) do
    Process.send_after(self(), action, 5_000)
  end
end
