defmodule UmgHealthcareWeb.DashboardControllerTest do
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

  test "shows an empty state without prescriptions", %{conn: conn} do
    html = conn |> get(~p"/dashboard") |> html_response(200)

    assert html =~ "Mis próximas tomas"
    assert html =~ "No tienes tomas pendientes"
    assert html =~ "Actualizar"
  end

  test "shows the next dose and lets the patient mark it taken", %{conn: conn, patient: patient} do
    # An activity two hours from now: the dose is always pending.
    now = DateTime.utc_now()
    local = DateTime.shift_zone!(now, Scheduler.timezone())
    time = local |> DateTime.add(2, :hour) |> DateTime.to_time() |> Time.truncate(:second)
    activity = activity_fixture(patient, name: "Merienda", time_of_day: time)

    prescription_fixture(patient, doctor_user_fixture(),
      activity: activity,
      medication: medication_fixture(name: "Amoxicilina"),
      starts_on: Date.add(Scheduler.today(now), -1),
      duration_days: 5
    )

    html = conn |> get(~p"/dashboard") |> html_response(200)

    assert html =~ "Amoxicilina"
    assert html =~ "con Merienda"
    assert html =~ ~r/en (1 h 59|2 h 0) min/
    assert html =~ "Marcar tomada"

    # The dashboard also generates tomorrow's doses, so take the first group.
    [{_at, [dose]} | _later] = Tracking.upcoming(patient, now)
    conn = post(conn, ~p"/doses/#{dose.id}/take")
    assert redirected_to(conn) == ~p"/dashboard"

    html = conn |> get(~p"/dashboard") |> html_response(200)
    assert html =~ "Toma registrada"
    refute html =~ ~s(id="take-dose-#{dose.id}")
  end

  test "doctors are sent away", %{conn: conn} do
    conn = conn |> log_in_user(doctor_user_fixture()) |> get(~p"/dashboard")
    assert redirected_to(conn) == ~p"/"
  end
end
