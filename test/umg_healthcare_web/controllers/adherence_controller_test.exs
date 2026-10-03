defmodule UmgHealthcareWeb.AdherenceControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.Tracking
  alias UmgHealthcare.Tracking.Scheduler

  setup %{conn: conn} do
    patient = patient_fixture()
    %{conn: log_in_user(conn, patient.user), patient: patient}
  end

  test "shows missed doses from days the app was not opened", %{conn: conn, patient: patient} do
    today = Scheduler.today(DateTime.utc_now())
    # At 00:05 yesterday's dose is always past its deadline, whatever the time now.
    activity = activity_fixture(patient, name: "Al despertar", time_of_day: ~T[00:05:00])

    prescription_fixture(patient, doctor_user_fixture(),
      activity: activity,
      medication: medication_fixture(name: "Losartán"),
      starts_on: Date.add(today, -2),
      duration_days: 30
    )

    html = conn |> get(~p"/adherence") |> html_response(200)

    assert html =~ "Mi cumplimiento"
    assert html =~ "Últimos 30 días"
    assert html =~ "0%"
    assert html =~ "Losartán"
    assert html =~ "Omitida"
  end

  test "counts a taken dose", %{conn: conn, patient: patient} do
    today = Scheduler.today(DateTime.utc_now())
    activity = activity_fixture(patient, time_of_day: ~T[00:05:00])

    prescription_fixture(patient, doctor_user_fixture(),
      activity: activity,
      starts_on: Date.add(today, -1),
      duration_days: 1
    )

    [dose] = Tracking.generate_doses_for_day(patient, Date.add(today, -1))
    {:ok, _} = Tracking.mark_taken(dose, DateTime.add(dose.scheduled_at, 5, :minute))

    html = conn |> get(~p"/adherence") |> html_response(200)

    assert html =~ "100%"
    assert html =~ "Tomada"
  end
end
