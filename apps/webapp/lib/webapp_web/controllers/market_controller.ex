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

  # TODO ERIC maybe delete both of these
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

  # TODO ERIC: Feel shame, refactor this. Maybe delete quickbuy and quicksell?
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

  def jita_price(conn, %{"search" => search_term}) do
  conn =
    search_term
    |> MarketService.current_jita_prices()
    |> assign_results(conn)
    |> assign(:searched_for, search_term)

  render(conn, "jita_price.html")
  end
  def jita_price(conn, _params) do
    render(conn, "jita_price.html")
  end

  @spec assign_results({:ok, {number(), number()}} | {:error, String.t()}, Plug.Conn.t()) :: Plug.Conn.t()
  defp assign_results({:ok, {highest_buy, lowest_sell}}, conn) do
    conn
    |> assign(:highest_buy, Formatter.shorthand(highest_buy))
    |> assign(:lowest_sell, Formatter.shorthand(lowest_sell))
  end
  defp assign_results({:error, message}, conn), do: assign(conn, :search_error, message)
end

