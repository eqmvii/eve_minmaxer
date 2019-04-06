defmodule Webapp.Model.Price do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Webapp.Repo

  # It's hacky, but now this should only return a price if it's fresh, and should

  @one_day_in_seconds 24 * 60 * 60
  # @one_week_in_seconds 7 * 24 * 60 * 60 # TODO ERIC decide on final time

  schema "prices" do
    field :adjusted_price, :float
    field :average_price, :float

    belongs_to :items, Webapp.Model.Item, foreign_key: :type_id

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = item, attrs) do
    item
    |> cast(attrs, [:adjusted_price, :average_price])
    |> validate_required([:adjusted_price, :average_price])
  end

  ##
  ## Functions
  ##

  # def get_type_id_from_name(name) do
  #   query =
  #     from item in Webapp.Model.Item,
  #       where: item.name == ^name,
  #       select: item.type_id

  #   Repo.one(query)
  # end

  def add_or_update(%{"type_id" => type_id, "adjusted_price" => adjusted_price, "average_price" => average_price}) do
    price = get_by_type_id(type_id)

    if is_nil(price) do
      Repo.insert!(%__MODULE__{type_id: type_id, adjusted_price: adjusted_price, average_price: average_price})
    else
      price = Ecto.Changeset.change price, adjusted_price: adjusted_price, average_price: average_price
      Repo.update!(price)
    end
  end
  def add_or_update(opts), do: raise inspect opts # TODO ERIC remove. This is raising on items with no average, like Erebus.

  defp get_by_type_id(type_id) do
    query =
      from price in __MODULE__,
        where: price.type_id == ^type_id

    Repo.one(query)
  end

  def get_fresh_price(type_id) do
    now = DateTime.to_unix(DateTime.utc_now)
    {:ok, stale_time} = DateTime.from_unix(now - @one_day_in_seconds)

    query =
      from price in __MODULE__,
        where: price.type_id == ^type_id and price.updated_at > ^stale_time,
        select: price.average_price

    Repo.one(query) # TODO ERIC: return all of the data instead?
  end

  # def get_all() do
  #   Repo.all(__MODULE__)
  # end
end
