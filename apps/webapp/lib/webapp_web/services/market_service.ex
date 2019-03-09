defmodule WebappWeb.MarketService do
  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Testtable

  def hello do
    "world"
  end

  def item_search(search_term) do
    type_id = EsiApi.item_search(search_term)
    price = EsiApi.price_from_type_id(type_id)

    price
  end
  def item_search(_), do: "Error: Invalid Search Input"
end

