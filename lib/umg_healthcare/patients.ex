defmodule UmgHealthcare.Patients do
  @moduledoc "Patient profiles, their allergies and clinical history."

  import Ecto.Query, warn: false

  alias UmgHealthcare.Accounts.User
  alias UmgHealthcare.Patients.{Allergy, MedicalRecord, Patient}
  alias UmgHealthcare.Repo

  ## Patients

  def create_patient(%User{id: user_id}, attrs \\ %{}) do
    %Patient{user_id: user_id}
    |> Patient.changeset(attrs)
    |> Repo.insert()
  end

  def get_patient!(id) do
    Patient |> Repo.get!(id) |> Repo.preload(:user)
  end

  def get_patient_for_user!(%User{id: user_id}) do
    Patient |> Repo.get_by!(user_id: user_id) |> Repo.preload(:user)
  end

  # Patients whose name contains `search` (case-insensitive), ordered by name.
  def list_patients(search \\ "") do
    pattern = "%#{search}%"

    Patient
    |> join(:inner, [p], u in assoc(p, :user))
    |> where([_p, u], ilike(u.full_name, ^pattern))
    |> order_by([_p, u], asc: u.full_name)
    |> preload([_p, u], user: u)
    |> Repo.all()
  end

  def change_patient(%Patient{} = patient, attrs \\ %{}) do
    Patient.changeset(patient, attrs)
  end

  def update_patient(%Patient{} = patient, attrs) do
    patient
    |> Patient.changeset(attrs)
    |> Repo.update()
  end

  ## Allergies

  def list_allergies(%Patient{id: patient_id}) do
    Allergy
    |> where(patient_id: ^patient_id)
    |> order_by(asc: :substance)
    |> Repo.all()
  end

  def get_allergy!(%Patient{id: patient_id}, id) do
    Repo.get_by!(Allergy, id: id, patient_id: patient_id)
  end

  def create_allergy(%Patient{id: patient_id}, attrs) do
    %Allergy{patient_id: patient_id}
    |> Allergy.changeset(attrs)
    |> Repo.insert()
  end

  def delete_allergy(%Allergy{} = allergy), do: Repo.delete(allergy)

  def change_allergy(%Allergy{} = allergy, attrs \\ %{}) do
    Allergy.changeset(allergy, attrs)
  end

  ## Medical records

  def list_medical_records(%Patient{id: patient_id}) do
    MedicalRecord
    |> where(patient_id: ^patient_id)
    |> order_by(desc: :recorded_on, desc: :id)
    |> preload(:doctor)
    |> Repo.all()
  end

  # Only doctors can write in the clinical history.
  def create_medical_record(%Patient{id: patient_id}, %User{role: :doctor, id: doctor_id}, attrs) do
    %MedicalRecord{patient_id: patient_id, doctor_id: doctor_id}
    |> MedicalRecord.changeset(attrs)
    |> Repo.insert()
  end

  def change_medical_record(%MedicalRecord{} = record, attrs \\ %{}) do
    MedicalRecord.changeset(record, attrs)
  end

  # Full record: user, allergies and clinical history (with its doctor).
  def record_for_patient(%Patient{} = patient) do
    records_query = from r in MedicalRecord, order_by: [desc: r.recorded_on, desc: r.id]
    allergies_query = from a in Allergy, order_by: a.substance

    Repo.preload(
      patient,
      [user: [], allergies: allergies_query, medical_records: {records_query, :doctor}],
      force: true
    )
  end
end
