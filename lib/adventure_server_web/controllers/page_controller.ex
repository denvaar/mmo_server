defmodule AdventureServerWeb.PageController do
  use AdventureServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
