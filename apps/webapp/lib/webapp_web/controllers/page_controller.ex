defmodule WebappWeb.PageController do
  use WebappWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:name, "Eric Mancini")
    |> assign(:plex_price, EsiApi.plex_price())
    |> render("index.html")
  end
end

