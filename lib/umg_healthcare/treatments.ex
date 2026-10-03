defmodule UmgHealthcare.Treatments do
  @moduledoc "Prescriptions and their daily schedules: what is current and what needs renewal."

  import Ecto.Query, warn: false

  alias UmgHealthcare.Accounts.User
  alias UmgHealthcare.Patients.Patient
  alias UmgHealthcare.Repo
  alias UmgHealthcare.Treatments.{DoseSchedule, Prescription}

  @renewal_days 3

  # Only doctors can prescribe.
  def create_prescription(%Patient{id: patient_id}, %User{role: :doctor, id: doctor_id}, attrs) do
    %Prescription{patient_id: patient_id, doctor_id: doctor_id}
    |> Prescription.changeset(attrs)
    |> Repo.insert()
  end

  def change_prescription(%Prescription{} = prescription, attrs \\ %{}) do
    Prescription.changeset(prescription, attrs)
  end

  def get_prescription!(id) do
    Prescription
    |> Repo.get!(id)
    |> Repo.preload([:medication, :doctor, dose_schedules: :activity])
  end

  # All prescriptions of a patient, newest first.
  def list_prescriptions(%Patient{id: patient_id}) do
    Prescription
    |> where(patient_id: ^patient_id)
    |> order_by(desc: :starts_on, desc: :id)
    |> preload([:medication, :doctor, dose_schedules: :activity])
    |> Repo.all()
  end

  # Current medications: active and not yet finished.
  def list_current(%Patient{} = patient, %Date{} = today) do
    patient |> list_prescriptions() |> Enum.filter(&current?(&1, today))
  end

  # Past medications: completed, renewed or already expired.
  def list_past(%Patient{} = patient, %Date{} = today) do
    patient |> list_prescriptions() |> Enum.reject(&current?(&1, today))
  end

  defp current?(%Prescription{status: :active} = prescription, today) do
    Date.compare(Prescription.ends_on(prescription), today) != :lt
  end

  defp current?(_prescription, _today), do: false

  def complete_prescription(%Prescription{} = prescription),
    do: set_status(prescription, :completed)

  def renew_prescription(%Prescription{} = prescription), do: set_status(prescription, :renewed)

  defp set_status(prescription, status) do
    prescription
    |> Ecto.Changeset.change(status: status)
    |> Repo.update()
  end

  # Active prescriptions of a doctor ending in `days` days or less (expired ones included).
  def due_for_renewal(%User{id: doctor_id}, %Date{} = today, days \\ @renewal_days) do
    Prescription
    |> where(doctor_id: ^doctor_id, status: :active)
    |> preload([:medication, patient: :user])
    |> Repo.all()
    |> Enum.filter(fn prescription ->
      Date.diff(Prescription.ends_on(prescription), today) <= days
    end)
    |> Enum.sort_by(&Prescription.ends_on/1, Date)
  end

  # Schedules of the patient's prescriptions active on `date`, with activity and medication.
  def active_schedules_for(%Patient{id: patient_id}, %Date{} = date) do
    DoseSchedule
    |> join(:inner, [s], p in assoc(s, :prescription))
    |> where([_s, p], p.patient_id == ^patient_id and p.status == :active)
    |> preload([_s, p], [:activity, prescription: {p, :medication}])
    |> Repo.all()
    |> Enum.filter(&Prescription.active_on?(&1.prescription, date))
  end
end
