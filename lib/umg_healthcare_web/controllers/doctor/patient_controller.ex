defmodule UmgHealthcareWeb.Doctor.PatientController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.{Patients, Tracking, Treatments}
  alias UmgHealthcare.Patients.{Allergy, MedicalRecord}
  alias UmgHealthcare.Tracking.Scheduler

  def index(conn, params) do
    query = Map.get(params, "q", "")
    render(conn, :index, query: query, patients: Patients.list_patients(query))
  end

  def show(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    now = DateTime.utc_now()
    today = Scheduler.today(now)

    Tracking.ensure_doses(patient, Date.add(today, -29), today)

    render(conn, :show,
      patient: patient,
      record: Patients.record_for_patient(patient),
      current: Treatments.list_current(patient, today),
      past: Treatments.list_past(patient, today),
      adherence: Tracking.adherence(patient, Date.add(today, -29), today, now),
      now: now,
      allergy_form: to_form(Patients.change_allergy(%Allergy{})),
      record_form: to_form(Patients.change_medical_record(%MedicalRecord{}))
    )
  end
end
