defmodule UmgHealthcareWeb.Doctor.MedicalRecordController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Patients

  def create(conn, %{"patient_id" => patient_id, "medical_record" => params}) do
    patient = Patients.get_patient!(patient_id)
    doctor = conn.assigns.current_scope.user

    conn =
      case Patients.create_medical_record(patient, doctor, params) do
        {:ok, _record} ->
          put_flash(conn, :info, "Registro agregado.")

        {:error, _changeset} ->
          put_flash(
            conn,
            :error,
            "No se pudo agregar: el tipo, el título y la fecha son obligatorios."
          )
      end

    redirect(conn, to: ~p"/doctor/patients/#{patient.id}")
  end
end
