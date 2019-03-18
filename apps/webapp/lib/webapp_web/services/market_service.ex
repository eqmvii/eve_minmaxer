defmodule WebappWeb.MarketService do
  alias Webapp.Model.Item
  alias Webapp.Model.Price

  def hello do
    "world"
  end

  def item_search(search_term) do # TODO ERIC -- html encode the spaces for multi word items
    with {:ok, type_id} <- get_type_id(search_term),
         {:ok, price} <- get_price(type_id)
    do
      {:ok, price}
    else
      err -> err
    end
  end

  ### Private Methods

  defp get_type_id(search_term) do
    case Item.get_type_id_from_name(search_term) do
      nil -> get_type_id_from_api(search_term)
      type_id -> {:ok, type_id}
    end
  end

  defp get_type_id_from_api(search_term) do
    case EsiApi.item_search(search_term) do
      {:error, message} -> {:error, message}
      {:ok, type_id} -> add_item_to_db({search_term, type_id})
    end
  end

  defp get_price(type_id) do
    case Price.get_current_price(type_id) do
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
    Webapp.Model.Price.add_new(price)

    {:ok, price}
  end
end

