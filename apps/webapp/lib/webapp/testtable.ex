defmodule Webapp.Testtable do
  use Ecto.Schema
  import Ecto.Changeset


  schema "testtable" do
    field :name, :string
  end

  @doc false
  # def changeset(%__MODULE__{} = user, attrs) do
  #   user
  #   |> cast(attrs, [:name, :username])
  #   |> validate_required([:name, :username])
  #   |> unique_constraint(:username)
  # end
end
