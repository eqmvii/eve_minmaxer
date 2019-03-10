defmodule Webapp.Model.Price do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Webapp.Repo

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

  def add_new(%{"type_id" => type_id, "adjusted_price" => adjusted_price, "average_price" => average_price}) do
    Repo.insert!(%__MODULE__{type_id: type_id, adjusted_price: adjusted_price, average_price: average_price})
  end
  def add_new(opts), do: raise inspect opts

  def get_current_price(type_id) do # TODO ERIC: Refactor this to only select a fresh price, like one less than a certain age? For now this saves one price forever, which is not ideal.
    query =
      from price in __MODULE__,
        where: price.type_id == ^type_id,
        select: price.average_price

    Repo.one(query)
  end

  # def get_all() do
  #   Repo.all(__MODULE__)
  # end
end
