defmodule UmgHealthcare.Repo.Migrations.CreatePrescriptions do
  use Ecto.Migration

  def change do
    create table(:prescriptions) do
      add :patient_id, references(:patients, on_delete: :delete_all), null: false
      add :doctor_id, references(:users, on_delete: :nilify_all)
      add :medication_id, references(:medications, on_delete: :restrict), null: false
      add :dose, :string, null: false
      add :instructions, :text
      add :starts_on, :date, null: false
      add :duration_days, :integer, null: false
      add :status, :string, null: false, default: "active"

      timestamps(type: :utc_datetime)
    end

    create index(:prescriptions, [:patient_id, :status])
    create index(:prescriptions, [:doctor_id, :status])

    create table(:dose_schedules) do
      add :prescription_id, references(:prescriptions, on_delete: :delete_all), null: false
      add :activity_id, references(:activities, on_delete: :restrict), null: false
      add :offset_minutes, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:dose_schedules, [:prescription_id])
    create index(:dose_schedules, [:activity_id])
  end
end
