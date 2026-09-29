defmodule UmgHealthcare.Repo.Migrations.CreatePatientsAndAllergies do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :birth_date, :date
      add :phone, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:patients, [:user_id])

    create table(:allergies) do
      add :patient_id, references(:patients, on_delete: :delete_all), null: false
      add :substance, :string, null: false
      add :reaction, :string
      add :severity, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:allergies, [:patient_id])
  end
end
