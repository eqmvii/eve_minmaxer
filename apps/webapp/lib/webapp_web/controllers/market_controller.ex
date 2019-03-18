defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable
  alias WebappWeb.MarketService

  def index(conn, %{"search" => search_term}) do
    item_search_results =
      case MarketService.item_search(search_term) do
        {:ok, price} -> price
        {:error, message} -> "Error with search: #{message}"
      end

    conn
    |> assign(:searched_for, search_term)
    |> assign(:search_result, item_search_results)
    |> render("index.html")
  end
  def index(conn, _params) do
    render(conn, "index.html")
  end
end

