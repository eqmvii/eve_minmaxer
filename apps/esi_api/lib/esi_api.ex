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
    {:ok, item_data} =
      request(@base_url <> "search/?categories=inventory_type&datasource=tranquility&language=en-us&search=#{item_name}&strict=true")

    case Poison.decode!(item_data) do
      %{"inventory_type" => inventory_type} -> Enum.at(inventory_type, 0)
      _ -> nil # TODO ERIC: Are we happy with this response messaging?
    end
  end

  def price_from_type_id(type_id) do
    {:ok, all_prices} = request(@base_url <> "markets/prices/?datasource=tranquility") # TODO ERIC Handle {:error, :timeout}



    item_price_info =
      all_prices
      |> Poison.decode!()
      |> Enum.filter(fn x -> x["type_id"] == type_id end) # PLEX type_id = 44992
      |> Enum.at(0)

     # TODO ERIC: Refactor this to not be an API-level side effect
    Webapp.Model.Price.add_new(item_price_info) # TODO ERIC This is very much the wrong place to do this

    item_price_info["average_price"]
  end

  def plex_price do
    # PLEX type_id = 44992
    {:ok, all_prices} = request(@base_url <> "markets/prices/?datasource=tranquility")

    plex_price_info =
      all_prices
      |> Poison.decode!()
      |> Enum.filter(fn x -> x["type_id"] == 44992 end) # PLEX type_id = 44992 # TODO ERIC make less bad
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
