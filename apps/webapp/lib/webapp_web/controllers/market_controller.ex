defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable
  alias WebappWeb.MarketService

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def search(conn, params) do
    IO.inspect params # TODO ERIC remove debugging

    item_search_results = MarketService.item_search(params["search"]["for"])

    conn
    |> assign(:searched_for, params["search"]["for"])
    |> assign(:search_result, item_search_results)
    |> render("index.html")
  end
end

