defmodule UmgHealthcareWeb.Doctor.AllergyController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Patients

  def create(conn, %{"patient_id" => patient_id, "allergy" => params}) do
    patient = Patients.get_patient!(patient_id)

    conn =
      case Patients.create_allergy(patient, params) do
        {:ok, _allergy} ->
          put_flash(conn, :info, "Alergia agregada.")

        {:error, _changeset} ->
          put_flash(
            conn,
            :error,
            "No se pudo agregar: la sustancia y la gravedad son obligatorias."
          )
      end

    redirect(conn, to: ~p"/doctor/patients/#{patient.id}")
  end

  def delete(conn, %{"patient_id" => patient_id, "id" => id}) do
    patient = Patients.get_patient!(patient_id)
    {:ok, _allergy} = patient |> Patients.get_allergy!(id) |> Patients.delete_allergy()

    conn
    |> put_flash(:info, "Alergia eliminada.")
    |> redirect(to: ~p"/doctor/patients/#{patient.id}")
  end
end
