defmodule UmgHealthcareWeb.Doctor.PrescriptionControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.Tracking.Scheduler
  alias UmgHealthcare.Treatments

  setup %{conn: conn} do
    doctor = doctor_user_fixture()
    patient = patient_fixture(full_name: "Ana López")
    %{conn: log_in_user(conn, doctor), doctor: doctor, patient: patient}
  end

  test "new warns when the patient has no routine", %{conn: conn, patient: patient} do
    html =
      conn |> get(~p"/doctor/patients/#{patient.id}/prescriptions/new") |> html_response(200)

    assert html =~ "Nueva receta para Ana López"
    assert html =~ "aún no ha definido su rutina"
  end

  test "create ignores empty rows and saves the rest", %{conn: conn, patient: patient} do
    activity = activity_fixture(patient)
    medication = medication_fixture(name: "Amoxicilina")

    conn =
      post(conn, ~p"/doctor/patients/#{patient.id}/prescriptions",
        prescription: %{
          medication_id: medication.id,
          dose: "1 cápsula",
          instructions: "Con agua",
          starts_on: "2026-09-28",
          duration_days: 7,
          dose_schedules: %{
            "0" => %{activity_id: activity.id, offset_minutes: 30},
            "1" => %{activity_id: "", offset_minutes: 0},
            "2" => %{activity_id: "", offset_minutes: 0}
          }
        }
      )

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert [%{dose_schedules: [%{offset_minutes: 30}]}] = Treatments.list_prescriptions(patient)

    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)
    assert html =~ "Receta guardada"
    assert html =~ "Amoxicilina"
  end

  test "create shows errors for invalid data", %{conn: conn, patient: patient} do
    activity_fixture(patient)

    html =
      conn
      |> post(~p"/doctor/patients/#{patient.id}/prescriptions",
        prescription: %{
          dose: "",
          duration_days: 0,
          dose_schedules: %{"0" => %{activity_id: "", offset_minutes: 0}}
        }
      )
      |> html_response(200)

    assert html =~ "be blank"
    assert html =~ "must be greater than 0"
  end

  test "complete finishes an active prescription", %{
    conn: conn,
    doctor: doctor,
    patient: patient
  } do
    prescription =
      prescription_fixture(patient, doctor, starts_on: Scheduler.today(DateTime.utc_now()))

    conn = patch(conn, ~p"/doctor/prescriptions/#{prescription.id}/complete")

    assert redirected_to(conn) == ~p"/doctor/patients/#{patient.id}"
    assert Treatments.get_prescription!(prescription.id).status == :completed

    html = conn |> get(~p"/doctor/patients/#{patient.id}") |> html_response(200)
    assert html =~ "Receta finalizada"
    assert html =~ "Finalizada"
  end
end
