defmodule Webapp.Repo.Migrations.Items do
  use Ecto.Migration

  def change do
    create table("items") do
      add :name,    :string
      add :type_id, :integer

      timestamps()
    end
  end
end
