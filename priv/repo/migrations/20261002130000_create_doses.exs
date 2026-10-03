defmodule UmgHealthcare.Repo.Migrations.CreateDoses do
  use Ecto.Migration

  def change do
    create table(:doses) do
      add :patient_id, references(:patients, on_delete: :delete_all), null: false
      add :dose_schedule_id, references(:dose_schedules, on_delete: :delete_all), null: false
      add :scheduled_at, :utc_datetime, null: false
      add :taken_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:doses, [:dose_schedule_id, :scheduled_at])
    create index(:doses, [:patient_id, :scheduled_at])
  end
end
