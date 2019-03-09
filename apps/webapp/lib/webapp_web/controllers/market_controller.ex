defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Testtable
  alias WebappWeb.MarketService

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def search(conn, params) do
    IO.inspect params

    conn
    |> assign(:test_message, MarketService.hello())
    |> assign(:searched_for, params["search"]["for"])
    |> render("index.html")
  end
end

