defmodule Webapp.Repo.Migrations.Prices do
  use Ecto.Migration

  # adjusted_price: used for internal purposes and less manipulable?
  # average_price: raw average?

  def change do
    create index("items", ["type_id"], unique: true)

    create table("prices") do
      add :type_id, references("items", column: "type_id")
      add :adjusted_price, :float
      add :average_price, :float

      timestamps()
    end
  end
end
