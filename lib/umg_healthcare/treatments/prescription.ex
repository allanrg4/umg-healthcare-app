defmodule UmgHealthcare.Treatments.Prescription do
  @moduledoc "A prescription: one medication for one patient during a number of days."

  use Ecto.Schema
  import Ecto.Changeset

  schema "prescriptions" do
    field :dose, :string
    field :instructions, :string
    field :starts_on, :date
    field :duration_days, :integer
    field :status, Ecto.Enum, values: [:active, :completed, :renewed], default: :active

    belongs_to :patient, UmgHealthcare.Patients.Patient
    belongs_to :doctor, UmgHealthcare.Accounts.User
    belongs_to :medication, UmgHealthcare.Medications.Medication
    has_many :dose_schedules, UmgHealthcare.Treatments.DoseSchedule, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, [:medication_id, :dose, :instructions, :starts_on, :duration_days])
    |> validate_required([:medication_id, :dose, :starts_on, :duration_days])
    |> validate_length(:dose, max: 120)
    |> validate_number(:duration_days, greater_than: 0)
    |> cast_assoc(:dose_schedules, required: true)
    |> assoc_constraint(:medication)
  end

  # Last day of the treatment (the start day counts as day one).
  def ends_on(%__MODULE__{starts_on: starts_on, duration_days: days}) do
    Date.add(starts_on, days - 1)
  end

  # Is the prescription active and does the date fall inside the treatment?
  def active_on?(%__MODULE__{status: :active} = prescription, %Date{} = date) do
    Date.compare(date, prescription.starts_on) != :lt and
      Date.compare(date, ends_on(prescription)) != :gt
  end

  def active_on?(_prescription, _date), do: false
end
