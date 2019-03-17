defmodule WebappWeb.MarketService do
  alias Webapp.Model.Item
  alias Webapp.Model.Price

  def hello do
    "world"
  end

  # TODO ERIC Probably refactor all of this

  def item_search(search_term) do # TODO ERIC -- html encode the spaces for multi word items
    with {:ok, type_id} <- get_type_id(search_term),
         {:ok, price} <- get_price(type_id)
    do
      {:ok, price}
    else
      err -> err
    end
  end

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

  defp get_price(nil), do: {:error, "Error: Invalid Search Input"}
  defp get_price(type_id) do
    case Price.get_current_price(type_id) do
      nil -> EsiApi.price_from_type_id(type_id)
      price -> {:ok, price}
    end
  end

  # TODO ERIC consider better error handling here?
  defp add_item_to_db({name, type_id}) do
    Item.add_new(name, type_id)

    {:ok, type_id}
  end
end

