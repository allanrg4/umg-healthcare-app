defmodule UmgHealthcareWeb.Doctor.AllergyControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures

  alias UmgHealthcare.Patients

  setup %{conn: conn} do
    %{conn: log_in_user(conn, doctor_user_fixture()), patient: patient_fixture()}
  end

  test "create adds an allergy", %{conn: conn, patient: patient} do
    conn =
      post(conn, ~p"/doctor/patients/#{patient.id}/allergies",
        allergy: %{substance: "Polen", reaction: "Estornudos", severity: "mild"}
      )

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert [%{substance: "Polen"}] = Patients.list_allergies(patient)

    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)
    assert html =~ "Alergia agregada"
    assert html =~ "Polen"
  end

  test "create with missing data shows an error flash", %{conn: conn, patient: patient} do
    conn = post(conn, ~p"/doctor/patients/#{patient.id}/allergies", allergy: %{substance: ""})

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)
    assert html =~ "No se pudo agregar"
    assert [] = Patients.list_allergies(patient)
  end

  test "delete removes an allergy", %{conn: conn, patient: patient} do
    allergy = allergy_fixture(patient)

    conn = delete(conn, ~p"/doctor/patients/#{patient.id}/allergies/#{allergy.id}")

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert [] = Patients.list_allergies(patient)
  end
end
