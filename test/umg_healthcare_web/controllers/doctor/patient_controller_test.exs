defmodule UmgHealthcareWeb.Doctor.PatientControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.Tracking.Scheduler

  setup %{conn: conn} do
    doctor = doctor_user_fixture(full_name: "Dr. Luis Gómez")
    %{conn: log_in_user(conn, doctor), doctor: doctor}
  end

  test "index lists and searches patients", %{conn: conn} do
    patient_fixture(full_name: "Ana López")
    patient_fixture(full_name: "Carlos Pérez")

    html = conn |> get(~p"/doctor/patients") |> html_response(200)
    assert html =~ "Ana López"
    assert html =~ "Carlos Pérez"

    html = conn |> get(~p"/doctor/patients", q: "carl") |> html_response(200)
    refute html =~ "Ana López"
    assert html =~ "Carlos Pérez"
  end

  test "show renders the whole record", %{conn: conn, doctor: doctor} do
    patient = patient_fixture(full_name: "Ana López")
    allergy_fixture(patient, substance: "Penicilina")
    medical_record_fixture(patient, doctor, title: "Hipertensión", kind: :diagnosis)
    today = Scheduler.today(DateTime.utc_now())

    prescription_fixture(patient, doctor,
      activity: activity_fixture(patient),
      medication: medication_fixture(name: "Losartán"),
      starts_on: today,
      duration_days: 30
    )

    old = prescription_fixture(patient, doctor, starts_on: Date.add(today, -60), duration_days: 5)

    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)

    assert html =~ "Ana López"
    assert html =~ "Penicilina"
    assert html =~ "Hipertensión"
    assert html =~ "Diagnóstico"
    assert html =~ "Dr. Luis Gómez"
    assert html =~ "Losartán"
    assert html =~ "con Desayuno"
    assert html =~ old.medication.name
    assert html =~ "Cumplimiento"
  end

  test "patients are sent away", %{conn: conn} do
    conn = conn |> log_in_user(patient_user_fixture()) |> get(~p"/doctor/patients")
    assert redirected_to(conn) == ~p"/"
  end
end
