defmodule UmgHealthcareWeb.PageControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures

  test "GET / sends anonymous visitors to login", %{conn: conn} do
    assert redirected_to(get(conn, ~p"/")) == ~p"/users/log-in"
  end

  test "GET / sends patients to their dashboard", %{conn: conn} do
    conn = conn |> log_in_user(patient_fixture().user) |> get(~p"/")
    assert redirected_to(conn) == ~p"/dashboard"
  end

  test "GET / sends doctors to their patient list", %{conn: conn} do
    conn = conn |> log_in_user(doctor_user_fixture()) |> get(~p"/")
    assert redirected_to(conn) == "/doctor/patients"
  end
end
