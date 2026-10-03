defmodule UmgHealthcare.Repo.Migrations.CreateMedications do
  use Ecto.Migration

  def change do
    create table(:medications) do
      add :name, :string, null: false
      add :presentation, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:medications, [:name])
  end
end
