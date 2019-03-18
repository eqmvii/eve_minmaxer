defmodule WebappWeb.PageController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Model.Testtable

  def index(conn, _params) do
    # all of this is terrible hackery
    # just to test a DB connection sry programming gods
    all_data = get_test_data

    first_record = Enum.at(all_data, 0)

    name = first_record.name


    conn
    |> assign(:name, "Eric Mancini")
    |> assign(:plex_price, EsiApi.plex_price())
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
    with {:ok, injector_price} <- WebappWeb.MarketService.item_search("large%20skill%20injector"), # TODO ERIC ugh shame
         {:ok, plex_price} <- WebappWeb.MarketService.item_search("plex"),
         {:ok, extractor_price} <- WebappWeb.MarketService.item_search("skill%20extractor")
    do
      monthly_profit = calc_monthly_profic(injector_price, plex_price, extractor_price)
      {:ok, %{injector_price: nerdify(injector_price),
              plex_price: nerdify(plex_price),
              extractor_price: nerdify(extractor_price),
              monthly_profit: nerdify(monthly_profit)
             }
      }
    else
      {:error, message} -> {:error, "API fail of some kind. Could not fetch all skill prices. #{message}"}
      _ -> {:error, "Another API fail with no match?"}
    end
  end

  defp calc_monthly_profic(injector_price, plex_price, extractor_price) do
    # large skill injector - 40520
    # plex - 44992
    # skill extractor - 40519
    # sp per minute - 44.5 (+5 / + 4)
    # sp per hour - 2670

    # TODO: Tax Calcs

    monthly_sub_cost = 500 * plex_price

    monthly_sp_gained = 30 * 24 * 2670 # 1922400

    injectors_per_month = monthly_sp_gained / 500_000

    profit_per_injector = injector_price - extractor_price

    total = (injectors_per_month * profit_per_injector) - monthly_sub_cost

    total
  end

  defp nerdify(number) do # TODO refactor and/or move elsewhere -- view, something like conn common, etc.?
    digits =
      number
      |> round()
      |> to_string
      |> String.replace_leading("-", "")
      |> String.length()

    modifier =
      cond do
        digits >= 13 ->
          " Trillion"
        digits >= 10 ->
          " Billion"
        digits >= 7 ->
          " Million"
        true ->
          ""
      end

    divisor =
      case modifier do
        " Trillion" -> 1_000_000_000_000
        " Billion" -> 1_000_000_000
        " Million" -> 1_000_000
        "" -> 1
      end

    (number / divisor)
    |> Float.floor(2)
    |> to_string
    |> Kernel.<>(modifier)
  end
end

