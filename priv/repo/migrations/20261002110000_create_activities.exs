defmodule UmgHealthcare.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :patient_id, references(:patients, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :time_of_day, :time, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:activities, [:patient_id, :name])
  end
end
