defmodule WebappWeb.MarketController do
  use WebappWeb, :controller

  import Ecto.Query, warn: false
  alias Webapp.Repo
  alias Webapp.Testtable

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def search(conn, params) do
    IO.inspect params
    render(conn, "index.html")
  end
end

