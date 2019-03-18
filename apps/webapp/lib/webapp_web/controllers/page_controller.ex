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

  def skills(conn, _params) do # TODO ERIC finish this
    render(conn, "index.html")
  end
end

