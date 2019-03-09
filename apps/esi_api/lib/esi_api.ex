defmodule EsiApi do
  @moduledoc """
  An application to handle requests for information from the Eve: Online ESI API.
  """

  @base_url "https://esi.evetech.net/latest/"

  @spec hello() :: atom()
  def hello do
    :world
  end

  def item_search(item_name) do # TODO ERIC: Add configuration
    {:ok, item_data} = request(@base_url <> "search/?categories=inventory_type&datasource=tranquility&language=en-us&search=#{item_name}&strict=true")
    item_data = Poison.decode!(item_data)

    # raise inspect item_data, pretty: true, limit: :infinity
    item_data["inventory_type"]
    |> Enum.at(0)
  end

  def price_from_type_id(type_id) do
    {:ok, all_prices} = request(@base_url <> "markets/prices/?datasource=tranquility")

    item_price_info =
      all_prices
      |> Poison.decode!()
      |> Enum.filter(fn x -> x["type_id"] == type_id end) # PLEX type_id = 44992
      |> Enum.at(0)

    item_price_info["average_price"]
  end

  def plex_price do
    # PLEX type_id = 44992
    {:ok, all_prices} = request(@base_url <> "markets/prices/?datasource=tranquility")

    plex_price_info =
      all_prices
      |> Poison.decode!()
      |> Enum.filter(fn x -> x["type_id"] == 44992 end) # PLEX type_id = 44992
      |> Enum.at(0)

    plex_price_info["average_price"]
  end

  defp request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404 Not Founf"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
