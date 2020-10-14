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
      five_four_monthly_profit_main = calc_monthly_profit(injector_price, plex_price, extractor_price, 500, 2_670)
      # Only 485 PLEX required for multi-pilot training certificate
      five_four_monthly_profit_multi = calc_monthly_profit(injector_price, plex_price, extractor_price, 485, 2_670)

      four_four_monthly_profit_main = calc_monthly_profit(injector_price, plex_price, extractor_price, 500, 2_610)
      four_four_monthly_profit_multi = calc_monthly_profit(injector_price, plex_price, extractor_price, 485, 2_610)

      {:ok, %{injector_price: Formatter.shorthand(injector_price),
              plex_price: Formatter.shorthand(plex_price),
              extractor_price: Formatter.shorthand(extractor_price),
              five_four_monthly_profit_main: Formatter.shorthand(five_four_monthly_profit_main),
              five_four_monthly_profit_multi: Formatter.shorthand(five_four_monthly_profit_multi),
              four_four_monthly_profit_main: Formatter.shorthand(four_four_monthly_profit_main),
              four_four_monthly_profit_multi: Formatter.shorthand(four_four_monthly_profit_multi)
             }
      }
    else
      {:error, message} -> {:error, "API fail of some kind. Could not fetch all skill prices. #{message}"}
      _ -> {:error, "Another API fail with no match?"}
    end
  end

  # TODO ERIC: Determine if we should avoid looking at extractor market price and instead look at PLEX purchase
  defp calc_monthly_profit(injector_price, plex_price, extractor_price, num_plex_to_sub, sp_per_hour) do
    # large skill injector - 40520
    # plex - 44992
    # skill extractor - 40519
    # Formula: Primary_Attribute + 0.50 × Secondary_Attribute
    # Properly mapped, w +5 / +4 = 32 + (25 / 2)
    # sp per minute - 44.5 (+5 / + 4)
    # sp per hour - 2,670

    # P, +5/+5 - 1,944,000 per month (2,700 per hour)
    # P, +5/+4 - 1,922,400 per month (2,670 per hour)
    # P, +4/+4 - 1,879,200 (2,610 per hour)
    # P, +0/+0 - 1,620,000 per month (2,250 per hour)

    # Add 1000 to plex price, since that's around the minimum tick to place a higher bid
    plex_price = plex_price + 1000
    # Fee to play a buy order at TTT calculated 10/11/2020
    buy_order_fee = 0.01
    plex_price_after_broker_fee = (plex_price + (buy_order_fee * plex_price))

    monthly_sub_cost = num_plex_to_sub * plex_price_after_broker_fee

    monthly_sp_gained = 30 * 24 * sp_per_hour

    injectors_per_month = monthly_sp_gained / 500_000

    profit_per_injector = (injector_price * 0.94703547) - (112 * plex_price_after_broker_fee)
    # 5.3% ish tax + broker fee observed 9/23/2020
    # Current extractor sale is 10 for 1,120 plex so 112 plex each

    (injectors_per_month * profit_per_injector) - monthly_sub_cost
  end
end

