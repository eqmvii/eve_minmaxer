defmodule WebappWeb.ItemsController do
  use WebappWeb, :controller

  alias Webapp.Model.Item

  def index(conn, _params) do
    all_items = Item.get_all()

    conn
    |> assign(:items, all_items) # TODO ERIC present this better
    |> render("index.html")
  end
end

