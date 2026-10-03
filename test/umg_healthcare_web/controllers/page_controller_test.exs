defmodule UmgHealthcareWeb.PageControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures

  test "GET / shows the landing page to visitors", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    assert html =~ "Seguimiento de medicación"
    assert html =~ ~s(id="cta-register")
    assert html =~ ~s(id="cta-login")
  end

  test "GET / sends patients to their dashboard", %{conn: conn} do
    conn = conn |> log_in_user(patient_fixture().user) |> get(~p"/")
    assert redirected_to(conn) == ~p"/dashboard"
  end

  test "GET / sends doctors to their patient list", %{conn: conn} do
    conn = conn |> log_in_user(doctor_user_fixture()) |> get(~p"/")
    assert redirected_to(conn) == ~p"/doctor/patients"
  end
end
