defmodule WebappWeb.PageController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable
  alias WebappWeb.Formatter
  alias WebappWeb.MarketService

  def index(conn, _params) do
    # all of this is terrible hackery
    # just to test a DB connection sry programming gods
    all_data = get_test_data

    first_record = Enum.at(all_data, 0)

    name = first_record.name


    conn
    |> assign(:name, "Eric Mancini")
    |> assign(:plex_price, Formatter.shorthand(EsiApi.plex_price()))
    |> assign(:name_from_db, name)
    |> render("index.html")
  end

  def get_test_data do
    Repo.all(Testtable)
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
         {:ok, plex_price} <- MarketService.current_jita_low_sell("plex"),
         {:ok, extractor_price} <- MarketService.current_jita_low_sell("skill extractor")
    do
      monthly_profit = calc_monthly_profit(injector_price, plex_price, extractor_price)
      {:ok, %{injector_price: Formatter.shorthand(injector_price),
              plex_price: Formatter.shorthand(plex_price),
              extractor_price: Formatter.shorthand(extractor_price),
              monthly_profit: Formatter.shorthand(monthly_profit)
             }
      }
    else
      {:error, message} -> {:error, "API fail of some kind. Could not fetch all skill prices. #{message}"}
      _ -> {:error, "Another API fail with no match?"}
    end
  end

  defp calc_monthly_profit(injector_price, plex_price, extractor_price) do
    # large skill injector - 40520
    # plex - 44992
    # skill extractor - 40519
    # sp per minute - 44.5 (+5 / + 4)
    # sp per hour - 2670

    # TODO: Tax Calcs

    monthly_sub_cost = 500 * plex_price

    monthly_sp_gained = 30 * 24 * 2670 # 1922400

    injectors_per_month = monthly_sp_gained / 500_000

    profit_per_injector = (injector_price * 0.9694) - extractor_price# 3%ish sales tax? Roughly accurate for me 4/8/2019

    total = (injectors_per_month * profit_per_injector) - monthly_sub_cost

    total
  end
end

