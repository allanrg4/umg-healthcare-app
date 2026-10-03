defmodule UmgHealthcare.PatientsFixtures do
  @moduledoc "Test helpers for the `UmgHealthcare.Patients` context."

  import UmgHealthcare.AccountsFixtures

  alias UmgHealthcare.Patients

  def patient_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    {full_name, attrs} = Map.pop(attrs, :full_name, "Ana López")

    {user, attrs} =
      Map.pop_lazy(attrs, :user, fn -> patient_user_fixture(full_name: full_name) end)

    {:ok, patient} = Patients.create_patient(user, attrs)
    Patients.get_patient!(patient.id)
  end

  def allergy_fixture(patient, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{substance: "Penicilina", reaction: "Urticaria", severity: :moderate})

    {:ok, allergy} = Patients.create_allergy(patient, attrs)
    allergy
  end

  def medical_record_fixture(patient, doctor, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        kind: :consultation,
        title: "Consulta general",
        details: "Sin novedades",
        recorded_on: ~D[2026-09-28]
      })

    {:ok, record} = Patients.create_medical_record(patient, doctor, attrs)
    record
  end
end
