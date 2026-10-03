defmodule UmgHealthcareWeb.Doctor.PrescriptionController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.{Medications, Patients, Routines, Treatments}
  alias UmgHealthcare.Tracking.Scheduler
  alias UmgHealthcare.Treatments.{DoseSchedule, Prescription}
  alias UmgHealthcareWeb.Formatters

  # The form always shows three rows; empty ones are ignored on save.
  @rows 3

  def new(conn, %{"patient_id" => patient_id}) do
    patient = Patients.get_patient!(patient_id)

    prescription = %Prescription{
      starts_on: Scheduler.today(DateTime.utc_now()),
      duration_days: 7,
      dose_schedules: List.duplicate(%DoseSchedule{}, @rows)
    }

    render_new(conn, patient, Treatments.change_prescription(prescription))
  end

  def create(conn, %{"patient_id" => patient_id, "prescription" => params}) do
    patient = Patients.get_patient!(patient_id)
    doctor = conn.assigns.current_scope.user

    case Treatments.create_prescription(patient, doctor, drop_blank_rows(params)) do
      {:ok, _prescription} ->
        conn
        |> put_flash(:info, "Receta guardada.")
        |> redirect(to: ~p"/doctor/patients/#{patient.id}")

      {:error, changeset} ->
        render_new(conn, patient, changeset)
    end
  end

  def complete(conn, %{"id" => id}) do
    prescription = Treatments.get_prescription!(id)
    {:ok, _prescription} = Treatments.complete_prescription(prescription)

    conn
    |> put_flash(:info, "Receta finalizada.")
    |> redirect(to: ~p"/doctor/patients/#{prescription.patient_id}")
  end

  defp render_new(conn, patient, changeset) do
    render(conn, :new,
      patient: patient,
      form: to_form(changeset),
      medication_options: medication_options(),
      activity_options: activity_options(patient)
    )
  end

  defp drop_blank_rows(params) do
    Map.update(params, "dose_schedules", %{}, fn rows ->
      rows
      |> Enum.reject(fn {_index, row} -> row["activity_id"] in [nil, ""] end)
      |> Map.new()
    end)
  end

  defp medication_options do
    for medication <- Medications.list_medications() do
      {"#{medication.name} (#{medication.presentation})", medication.id}
    end
  end

  defp activity_options(patient) do
    for activity <- Routines.list_activities(patient) do
      {"#{activity.name} (#{Formatters.format_time(activity.time_of_day)})", activity.id}
    end
  end
end
