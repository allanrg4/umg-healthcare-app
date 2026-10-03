defmodule UmgHealthcare.Tracking.Dose do
  @moduledoc "A concrete dose (schedule + date). `taken_at` stays nil until the patient marks it."

  use Ecto.Schema

  schema "doses" do
    field :scheduled_at, :utc_datetime
    field :taken_at, :utc_datetime

    belongs_to :patient, UmgHealthcare.Patients.Patient
    belongs_to :dose_schedule, UmgHealthcare.Treatments.DoseSchedule

    timestamps(type: :utc_datetime)
  end
end
