defmodule UmgHealthcare.Repo.Migrations.CreateMedicalRecords do
  use Ecto.Migration

  def change do
    create table(:medical_records) do
      add :patient_id, references(:patients, on_delete: :delete_all), null: false
      add :doctor_id, references(:users, on_delete: :nilify_all)
      add :kind, :string, null: false
      add :title, :string, null: false
      add :details, :text
      add :recorded_on, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:medical_records, [:patient_id, :recorded_on])
    create index(:medical_records, [:doctor_id])
  end
end
