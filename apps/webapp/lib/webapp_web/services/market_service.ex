defmodule WebappWeb.MarketService do
  alias Webapp.Model.Item
  alias Webapp.Model.Price

  def hello do
    "world"
  end

  # TODO ERIC Probably refactor all of this

  def item_search(search_term) do # TODO ERIC -- html encode the spaces for multi word items
    search_term
    |> get_type_id_from_db()
    |> get_type_id_from_api()
    |> get_price()
  end

  @spec get_type_id_from_db(String.t()) :: {String.t(), String.t()} | {String.t(), nil}
  defp get_type_id_from_db(name) do
    {name, Item.get_type_id_from_name(name)}
  end

  defp get_type_id_from_api({name, nil}) do
    case EsiApi.item_search(name) do
      nil -> {name, nil}
      type_id -> add_item_to_db({name, type_id})
    end
  end
  defp get_type_id_from_api(complete_tuple), do: complete_tuple # TODO ERIC rename

  defp get_price({_name, nil}), do: "Error: Invalid Search Input"
  defp get_price({_name, type_id}) do
    case Price.get_current_price(type_id) do
      nil -> EsiApi.price_from_type_id(type_id)
      price -> price
    end
  end

  defp add_item_to_db({name, type_id}) do
    Item.add_new(name, type_id)

    {name, type_id}
  end
end

