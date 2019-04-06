defmodule WebappWeb.MarketService do
  alias Webapp.Model.Item
  alias Webapp.Model.Price

  def hello do
    "world"
  end

  @spec current_jita_prices(String.t()) :: {:ok, tuple()} # TODO make this a struct or something maybe?
  def current_jita_prices(search_term) do
    search_term = String.downcase(search_term)

    with {:ok, type_id} <- get_type_id(search_term),
         {:ok, {highest_buy, lowest_sell}} <- EsiApi.jita_search(type_id, %{"order_type" => "all"})
    do
         {:ok, {highest_buy, lowest_sell}}
    else
         err -> err
    end
  end

  def item_search(search_term) do
    with {:ok, type_id} <- get_type_id(search_term),
         {:ok, price} <- get_price(type_id)
    do
      {:ok, price}
    else
      err -> err
    end
  end

  @spec get_type_id(String.t()) :: {:ok, pos_integer()} | {:error, String.t()}
  def get_type_id(search_term) do
    search_term = String.downcase(search_term)

    case Item.get_type_id_from_name(search_term) do
      nil -> get_type_id_from_api(search_term)
      type_id -> {:ok, type_id}
    end
  end

  ### Private Methods

  defp get_type_id_from_api(search_term) do
    case EsiApi.item_search(search_term) do
      {:ok, type_id} -> add_item_to_db({search_term, type_id})
      {:error, message} -> {:error, message}
    end
  end

  defp get_price(type_id) do
    case Price.get_fresh_price(type_id) do
      nil -> get_price_from_api(type_id)
      price -> {:ok, price}
    end
  end

  defp get_price_from_api(type_id) do
    case EsiApi.price_from_type_id(type_id) do
      {:ok, price} -> save_price_to_db(price)
      {:error, message} -> {:error, message} # TODO refactor line?
    end
  end

  #
  # Persistance
  #

  defp add_item_to_db({name, type_id}) do
    Item.add_new(name, type_id)

    {:ok, type_id}
  end

  defp save_price_to_db(price) do
    Webapp.Model.Price.add_or_update(price)

    {:ok, price["average_price"]}
  end
end

