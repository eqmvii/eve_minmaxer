defmodule EsiApi do
  @moduledoc """
  An application to handle requests for information from the Eve: Online ESI API.
  """

  @base_url "https://esi.evetech.net/latest"
  @jita_region_id 10000002
  @jita_station_id 60003760

  @spec hello() :: atom()
  def hello do
    :world
  end

  # Test it:
  #
  # EsiApi.jita_sell_search(28710)
  #
  # Data Structure:
  #
  # {
  #   "duration": 90,
  #   "is_buy_order": false,
  #   "issued": "2019-02-17T10:00:08Z",
  #   "location_id": 60003469,
  #   "min_volume": 1,
  #   "order_id": 5323499021,
  #   "price": 4999887.99,
  #   "range": "region",
  #   "system_id": 30000142,
  #   "type_id": 44992,
  #   "volume_remain": 9,
  #   "volume_total": 10
  # }
  def jita_search(type_id, opts) do # TODO ERIC This will only do the first page for now
    request_string =
      "#{@base_url}/markets/#{@jita_region_id}/orders/?datasource=tranquility&order_type=#{opts["order_type"]}&page=1&type_id=#{type_id}"

      basic_jita_market_search(request_string, opts)
  end

  def basic_jita_market_search(request_string, opts) do
    with {:ok, item_data} <- request(request_string),
         {:ok, decoded_data} <- parse_market_data(item_data),
         {:ok, extreme_price} <- fetch_extreme(decoded_data, opts)
    do
      {:ok, extreme_price}
    else
      err -> raise inspect err, pretty: true, limit: :infinity
    end
  end

  def item_search(item_name) do # TODO ERIC: Add configuration
    search_uri = "#{@base_url}/search/?categories=inventory_type&datasource=tranquility&language=en-us&search=#{URI.encode(item_name)}&strict=true"
    case request(search_uri) do
      {:ok, result} -> {:ok, parse_search_result(Poison.decode!(result))}
      err -> err
    end
  end

  #
  # Private Methods
  #

  @spec parse_search_result(map()) :: integer
  defp parse_search_result(%{"inventory_type" => [inventory_type]}), do: inventory_type
  # defp parse_search_result(unexpected_data), do: raise inspect unexpected_data


  defp parse_market_data(item_data) do
    case Poison.decode!(item_data) do
      item_data when is_list(item_data) -> {:ok, item_data}# raise inspect item_data, pretty: true, limit: :infinity
      _ -> raise inspect {:error, "Search Error: #{item_data}"}
    end
  end

  def fetch_extreme(decoded_data, %{"order_type" => "sell"}) do
    extreme_price =
      decoded_data
      |> Enum.reject(fn x -> x["location_id"] != @jita_station_id end)
      |> Enum.map(fn x -> x["price"] end)
      |> Enum.min()

    {:ok, extreme_price}
  end
  def fetch_extreme(decoded_data, %{"order_type" => "buy"}) do
    extreme_price =
      decoded_data
      |> Enum.reject(fn x -> x["location_id"] != @jita_station_id end)
      |> Enum.map(fn x -> x["price"] end)
      |> Enum.max()

    {:ok, extreme_price}
  end

  defp decode_item_data(item_data) do
    case Poison.decode!(item_data) do
      %{"inventory_type" => inventory_type} -> {:ok, Enum.at(inventory_type, 0)}
      _ -> {:error, "Search Error: #{item_data}"}
    end
  end

  def price_from_type_id(type_id) do
    {:ok, all_prices} = request(@base_url <> "/markets/prices/?datasource=tranquility") # TODO ERIC Handle {:error, :timeout}

    price_data =
      all_prices
      |> Poison.decode!()
      |> Enum.filter(fn x -> x["type_id"] == type_id end) # PLEX type_id = 44992
      |> Enum.at(0)

    {:ok, price_data}
  end

  def plex_price do
    # PLEX type_id = 44992
    {:ok, all_prices} = request(@base_url <> "/markets/prices/?datasource=tranquility")

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
        {:error, "404 Not Found"}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Error; response code #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
