defmodule UmgHealthcareWeb.Doctor.RenewalAlertControllerTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.Tracking.Scheduler
  alias UmgHealthcare.Treatments

  setup %{conn: conn} do
    doctor = doctor_user_fixture()
    patient = patient_fixture(full_name: "Ana López")
    %{conn: log_in_user(conn, doctor), doctor: doctor, patient: patient}
  end

  test "index lists prescriptions ending soon and renew removes them", ctx do
    today = Scheduler.today(DateTime.utc_now())

    soon =
      prescription_fixture(ctx.patient, ctx.doctor,
        medication: medication_fixture(name: "Metformina"),
        starts_on: Date.add(today, -5),
        duration_days: 7
      )

    prescription_fixture(ctx.patient, ctx.doctor,
      medication: medication_fixture(name: "Omeprazol"),
      starts_on: today,
      duration_days: 30
    )

    html = ctx.conn |> get(~p"/doctor/alerts") |> html_response(200)

    assert html =~ "Recetas por renovar"
    assert html =~ "Ana López"
    assert html =~ "Metformina"
    assert html =~ "Vence en 1 día"
    refute html =~ "Omeprazol"

    conn = patch(ctx.conn, ~p"/doctor/alerts/#{soon.id}/renew")
    assert redirected_to(conn) == ~p"/doctor/alerts"
    assert Treatments.get_prescription!(soon.id).status == :renewed

    html = conn |> get(~p"/doctor/alerts") |> html_response(200)
    assert html =~ "marcada como renovada"
    refute html =~ "Metformina"
  end

  test "index shows an empty state", ctx do
    html = ctx.conn |> get(~p"/doctor/alerts") |> html_response(200)
    assert html =~ "No hay recetas por renovar"
  end

  test "a doctor cannot renew another doctor's prescription", ctx do
    today = Scheduler.today(DateTime.utc_now())
    other = prescription_fixture(ctx.patient, doctor_user_fixture(), starts_on: today)

    conn = patch(ctx.conn, ~p"/doctor/alerts/#{other.id}/renew")

    assert redirected_to(conn) == ~p"/doctor/alerts"
    assert Treatments.get_prescription!(other.id).status == :active
  end
end
