defmodule UmgHealthcareWeb.ActivityControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures

  alias UmgHealthcare.Routines

  setup %{conn: conn} do
    patient = patient_fixture()
    %{conn: log_in_user(conn, patient.user), patient: patient}
  end

  test "index lists the activities", %{conn: conn, patient: patient} do
    activity_fixture(patient, name: "Cena", time_of_day: ~T[19:00:00])

    html = conn |> get(~p"/routine") |> html_response(200)

    assert html =~ "Mi rutina diaria"
    assert html =~ "Cena"
    assert html =~ "19:00"
  end

  test "create adds an activity and redirects", %{conn: conn, patient: patient} do
    conn = post(conn, ~p"/routine", activity: %{name: "Desayuno", time_of_day: "07:00"})
    assert redirected_to(conn) == ~p"/routine"

    html = conn |> get(~p"/routine") |> html_response(200)
    assert html =~ "Actividad guardada"
    assert html =~ "Desayuno"
    assert [%{name: "Desayuno"}] = Routines.list_activities(patient)
  end

  test "create shows validation errors", %{conn: conn} do
    html =
      conn
      |> post(~p"/routine", activity: %{name: "", time_of_day: ""})
      |> html_response(200)

    assert html =~ "be blank"
  end

  test "update changes the time", %{conn: conn, patient: patient} do
    activity = activity_fixture(patient)

    conn = put(conn, ~p"/routine/#{activity.id}", activity: %{time_of_day: "07:30"})
    assert redirected_to(conn) == ~p"/routine"
    assert Routines.get_activity!(patient, activity.id).time_of_day == ~T[07:30:00]
  end

  test "delete removes the activity", %{conn: conn, patient: patient} do
    activity = activity_fixture(patient)

    conn = delete(conn, ~p"/routine/#{activity.id}")
    assert redirected_to(conn) == ~p"/routine"
    assert [] = Routines.list_activities(patient)
  end

  test "patients cannot touch other patients' activities", %{conn: conn} do
    activity = activity_fixture(patient_fixture())

    assert_error_sent 404, fn -> get(conn, ~p"/routine/#{activity.id}/edit") end
  end

  test "doctors are sent away", %{conn: conn} do
    conn = conn |> log_in_user(doctor_user_fixture()) |> get(~p"/routine")
    assert redirected_to(conn) == ~p"/"
  end
end
