defmodule WebappWeb.PageController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias WebappWeb.Formatter
  alias WebappWeb.MarketService

  @moduledoc """
  An old test route. TODO: Remove
  """
  def index(conn, _params) do
    conn
    |> assign(:name, "Eric Mancini")
    |> assign(:plex_price, Formatter.shorthand(EsiApi.plex_price()))
    |> assign(:name_from_db, "not used anymore")
    |> render("index.html")
  end

  # TODO ERIC BUG: Doesn't work on first search, winds up multiplying tuples in a broken way
  def skills(conn, _params) do # TODO ERIC finish this, move elsewhere, factor in taxes, and get jita high/low
    case fetch_skill_data do
      {:ok, prices} -> render(conn, "skills.html", prices: prices)
      {:error, message} -> render(conn, "skill_error.html", message: message)
    end
  end

  defp fetch_skill_data do
    with {:ok, injector_price} <- MarketService.current_jita_low_sell("large skill injector"), # TODO ERIC ugh shame
         {:ok, plex_price} <- MarketService.current_jita_high_buy("plex"),
         {:ok, extractor_price} <- MarketService.current_jita_low_sell("skill extractor")
    do
      monthly_profit_main = calc_monthly_profit(injector_price, plex_price, extractor_price)
      # Only 485 PLEX required for multi-pilot training certificate
      monthly_profit_multi = calc_monthly_profit(injector_price, plex_price, extractor_price, 485)

      {:ok, %{injector_price: Formatter.shorthand(injector_price),
              plex_price: Formatter.shorthand(plex_price),
              extractor_price: Formatter.shorthand(extractor_price),
              monthly_profit_main: Formatter.shorthand(monthly_profit_main),
              monthly_profit_multi: Formatter.shorthand(monthly_profit_multi)
             }
      }
    else
      {:error, message} -> {:error, "API fail of some kind. Could not fetch all skill prices. #{message}"}
      _ -> {:error, "Another API fail with no match?"}
    end
  end

  # TODO ERIC: Determine if we should avoid looking at extractor market price and instead look at PLEX purchase
  defp calc_monthly_profit(injector_price, plex_price, extractor_price, num_plex_to_sub \\ 500) do
    # large skill injector - 40520
    # plex - 44992
    # skill extractor - 40519
    # sp per minute - 44.5 (+5 / + 4)
    # sp per hour - 2670

    # Add 1000 to plex price, since that's around the minimum tick to place a higher bid
    plex_price = plex_price + 1000
    # Fee to play a buy order at TTT calculated 10/11/2020
    buy_order_fee = 0.01
    plex_price_after_broker_fee = (plex_price + (buy_order_fee * plex_price))

    monthly_sub_cost = num_plex_to_sub * plex_price_after_broker_fee

    monthly_sp_gained = 30 * 24 * 2670 # 1922400

    injectors_per_month = monthly_sp_gained / 500_000

    profit_per_injector = (injector_price * 0.94703547) - (112 * plex_price_after_broker_fee)
    # 5.3% ish tax + broker fee observed 9/23/2020
    # Current extractor sale is 10 for 1,120 plex so 112 plex each

    total = (injectors_per_month * profit_per_injector) - monthly_sub_cost

    total
  end
end

