defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable
  alias WebappWeb.MarketService

  def index(conn, %{"search" => search_term}) do # TODO ERIC ugh make this dry with search
    # raise inspect search_term # TODO ERIC remove debugging

    item_search_results = MarketService.item_search(search_term)

    conn
    |> assign(:searched_for, search_term)
    |> assign(:search_result, item_search_results)
    |> render("index.html")
  end
  def index(conn, _params) do
    render(conn, "index.html")
  end

  def search(conn, params) do
    IO.inspect params # TODO ERIC remove debugging

    item_search_results = MarketService.item_search(params["search"])

    conn
    |> assign(:searched_for, params["search"])
    |> assign(:search_result, item_search_results)
    |> render("index.html")
  end
end

