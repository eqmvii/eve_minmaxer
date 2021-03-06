defmodule Webapp.Model.Item do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Webapp.Repo

  schema "items" do
    field :name, :string
    field :type_id, :integer

    has_many :prices, Webapp.Model.Price

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = item, attrs) do
    item
    |> cast(attrs, [:name, :type_id])
    |> validate_required([:name, :type_id])
    |> unique_constraint([:name, :type_id])
  end

  ##
  ## Functions
  ##

  def get_type_id_from_name(name) do
    query =
      from item in Webapp.Model.Item,
        where: item.name == ^name,
        select: item.type_id

    Repo.one(query)
  end

  def add_new(name, type_id) do
    Repo.insert!(%__MODULE__{name: name, type_id: type_id})
  end

  def get_all() do
    Repo.all(__MODULE__)
  end
end
