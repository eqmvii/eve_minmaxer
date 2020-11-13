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

  # On pages: A header will alert if there is more than one page via x-pages, see below response header example:
#   access-control-allow-credentials: true
#  access-control-allow-headers: Content-Type,Authorization,If-None-Match,X-User-Agent
#  access-control-allow-methods: GET,HEAD,OPTIONS
#  access-control-allow-origin: *
#  access-control-expose-headers: Content-Type,Warning,ETag,X-Pages,X-ESI-Error-Limit-Remain,X-ESI-Error-Limit-Reset
#  access-control-max-age: 600
#  allow: GET,HEAD,OPTIONS
#  cache-control: public
#  content-encoding: gzip
#  content-type: application/json; charset=UTF-8
#  date: Wed, 14 Oct 2020 18:33:17 GMT
#  etag: "871850fda5066e1071c295a59d93cb2612bdc7aba0e79d8df279cfb2"
#  expires: Wed, 14 Oct 2020 18:35:03 GMT
#  last-modified: Wed, 14 Oct 2020 18:30:03 GMT
#  status: 200
#  strict-transport-security: max-age=31536000
#  vary: Accept-Encoding
#  x-esi-error-limit-remain: 100
#  x-esi-error-limit-reset: 43
#  x-esi-request-id: 65fc16a5-9552-4e57-b542-8a0870b8646b
#  x-pages: 1

  def basic_jita_market_search(request_string, opts) do
    with {:ok, item_data} <- request(request_string),
         {:ok, decoded_data} <- parse_market_data(item_data),
         {:ok, result} <- fetch_extreme(decoded_data, opts)
    do
      {:ok, result}
    else
      err -> err
    end
  end

  def item_search(item_name) do # TODO ERIC: Add configuration
    search_uri = "#{@base_url}/search/?categories=inventory_type&datasource=tranquility&language=en-us&search=#{URI.encode(item_name)}&strict=true"
    case request(search_uri) do
      {:ok, result} -> parse_search_result(Poison.decode!(result))
      err -> err
    end
  end

  #
  # Private Methods
  #

  @spec parse_search_result(map()) :: {:ok, integer} | {:error, String.t()}
  defp parse_search_result(%{"inventory_type" => [inventory_type]}), do: {:ok, inventory_type}
  defp parse_search_result(_no_results), do: {:error, "No results from search"}


  defp parse_market_data(item_data) do
    case Poison.decode!(item_data) do
      item_data when is_list(item_data) -> {:ok, item_data}# raise inspect item_data, pretty: true, limit: :infinity
      _ -> raise inspect {:error, "Search Error: #{item_data}"}
    end
  end

  @spec fetch_extreme(map(), map()) :: {:ok, non_neg_integer()} | {:ok, {non_neg_integer(), non_neg_integer()}}
  def fetch_extreme(decoded_data, %{"order_type" => "sell"}) do
    lowest_sell_price =
      decoded_data
      |> Enum.reject(&(&1["is_buy_order"]))
      |> Enum.reject(fn x -> x["location_id"] != @jita_station_id end) # TODO ERIC shorthand notation
      |> Enum.map(fn x -> x["price"] end)
      |> Enum.min()

    {:ok, lowest_sell_price}
  rescue
    err -> {:error, "Extreme price error"}
  end
  def fetch_extreme(decoded_data, %{"order_type" => "buy"}) do
    highest_buy_price =
      decoded_data
      |> Enum.filter(&(&1["is_buy_order"]))
      |> Enum.reject(fn x -> x["location_id"] != @jita_station_id end)
      |> Enum.map(fn x -> x["price"] end)
      |> Enum.max()

    {:ok, highest_buy_price}
  rescue
    err -> {:error, "Extreme price error"}
  end
  def fetch_extreme(decoded_data, %{"order_type" => "all"}) do
    highest_buy = fetch_extreme(decoded_data, %{"order_type" => "buy"})
    lowest_sell = fetch_extreme(decoded_data, %{"order_type" => "sell"})

    parse_extreme_results(highest_buy, lowest_sell)
  end

  @spec parse_extreme_results({:ok, number()} | {:error, String.t()}, {:ok, number()} | {:error, String.t()}) :: {:ok, tuple()} | {:error, String.t()}
  defp parse_extreme_results({:ok, highest_buy}, {:ok, lowest_sell}), do: {:ok, {highest_buy, lowest_sell}}
  defp parse_extreme_results(_highest_buy, _lowest_sell), do: {:error, "Error fetching highest/lowest prices"}

  defp decode_item_data(item_data) do # TODO ERIC function unused now?
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
