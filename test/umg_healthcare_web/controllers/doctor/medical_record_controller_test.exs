defmodule UmgHealthcareWeb.Doctor.MedicalRecordControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures

  alias UmgHealthcare.Patients

  setup %{conn: conn} do
    doctor = doctor_user_fixture()
    %{conn: log_in_user(conn, doctor), doctor: doctor, patient: patient_fixture()}
  end

  test "create adds a record signed by the doctor", %{
    conn: conn,
    doctor: doctor,
    patient: patient
  } do
    conn =
      post(conn, ~p"/doctor/patients/#{patient.id}/medical_records",
        medical_record: %{
          kind: "test_result",
          title: "Glucosa",
          details: "95 mg/dL",
          recorded_on: "2026-09-28"
        }
      )

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert [%{title: "Glucosa", doctor_id: doctor_id}] = Patients.list_medical_records(patient)
    assert doctor_id == doctor.id

    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)
    assert html =~ "Registro agregado"
    assert html =~ "Glucosa"
  end

  test "create with missing data shows an error flash", %{conn: conn, patient: patient} do
    conn =
      post(conn, ~p"/doctor/patients/#{patient.id}/medical_records", medical_record: %{title: ""})

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert [] = Patients.list_medical_records(patient)
  end
end
