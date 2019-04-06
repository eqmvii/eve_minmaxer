defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable
  alias WebappWeb.MarketService
  alias WebappWeb.Formatter

  def index(conn, %{"search" => search_term}) do

    item_search_results =
      case MarketService.item_search(search_term) do
        {:ok, price} -> price
        {:error, message} -> "Error with search: #{message}"
      end

    conn
    |> assign(:searched_for, search_term)
    |> assign(:search_result, Formatter.shorthand(item_search_results))
    |> render("index.html")
  end
  def index(conn, _params) do
    render(conn, "index.html")
  end

  def quicksell(conn, %{"search" => search_term}) do
    # TODO move this all into a service instead
    type_id =
      case MarketService.get_type_id(search_term) do
        {:ok, type_id} -> type_id
        {:error, message} -> raise message # TODO handle this better
      end

    item_search_results =
      case EsiApi.jita_search(type_id, %{"order_type" => "sell"}) do
        {:ok, price} -> Formatter.shorthand(price)
        {:error, message} -> "Error with search: #{message}"
      end

    conn
    |> assign(:searched_for, type_id)
    |> assign(:search_result, item_search_results)
    |> render("quicksell.html")
  end
  def quicksell(conn, _params) do
    render(conn, "quicksell.html")
  end

  # TODO ERIC: Feel shame, refactor this.
  def quickbuy(conn, %{"search" => search_term}) do
    # TODO move this all into a service instead
    type_id =
      case MarketService.get_type_id(search_term) do
        {:ok, type_id} -> type_id
        {:error, message} -> raise message # TODO handle this better
      end

    item_search_results =
      case EsiApi.jita_search(type_id, %{"order_type" => "buy"}) do
        {:ok, price} -> Formatter.shorthand(price)
        {:error, message} -> "Error with search: #{message}"
      end

    conn
    |> assign(:searched_for, type_id)
    |> assign(:search_result, item_search_results)
    |> render("quicksell.html")
  end
end

