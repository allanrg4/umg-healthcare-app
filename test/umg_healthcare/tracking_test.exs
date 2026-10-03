defmodule UmgHealthcare.TrackingTest do
  use UmgHealthcare.DataCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.Tracking

  # Breakfast at 07:00 in Guatemala = 13:00 UTC.
  @date ~D[2026-09-28]
  @breakfast_utc ~U[2026-09-28 13:00:00Z]

  setup do
    patient = patient_fixture()
    doctor = doctor_user_fixture()
    activity = activity_fixture(patient)

    prescription =
      prescription_fixture(patient, doctor,
        starts_on: @date,
        duration_days: 7,
        activity: activity,
        medication: medication_fixture(name: "Amoxicilina")
      )

    %{patient: patient, doctor: doctor, activity: activity, prescription: prescription}
  end

  describe "generate_doses_for_day/2" do
    test "creates one dose per schedule at the computed time", ctx do
      assert [dose] = Tracking.generate_doses_for_day(ctx.patient, @date)
      assert dose.scheduled_at == @breakfast_utc
      assert dose.taken_at == nil
      assert dose.dose_schedule.prescription.medication.name == "Amoxicilina"
      assert dose.dose_schedule.activity.name == "Desayuno"
    end

    test "is idempotent", ctx do
      Tracking.generate_doses_for_day(ctx.patient, @date)
      assert [_] = Tracking.generate_doses_for_day(ctx.patient, @date)
    end

    test "creates nothing outside the treatment", ctx do
      assert [] = Tracking.generate_doses_for_day(ctx.patient, ~D[2026-10-20])
    end

    test "ensure_doses/3 covers every day in the range", ctx do
      assert :ok = Tracking.ensure_doses(ctx.patient, ~D[2026-09-27], ~D[2026-09-30])

      assert [] = Tracking.list_doses_for_day(ctx.patient, ~D[2026-09-27])
      assert [_] = Tracking.list_doses_for_day(ctx.patient, ~D[2026-09-28])
      assert [_] = Tracking.list_doses_for_day(ctx.patient, ~D[2026-09-30])
      assert [] = Tracking.list_doses_for_day(ctx.patient, ~D[2026-10-01])
    end
  end

  describe "upcoming/3" do
    test "groups pending doses by time and hides taken or missed ones", ctx do
      dinner = activity_fixture(ctx.patient, name: "Cena", time_of_day: ~T[19:00:00])
      prescription_fixture(ctx.patient, ctx.doctor, starts_on: @date, activity: dinner)
      prescription_fixture(ctx.patient, ctx.doctor, starts_on: @date, activity: ctx.activity)
      Tracking.generate_doses_for_day(ctx.patient, @date)

      dinner_utc = ~U[2026-09-29 01:00:00Z]

      assert [{@breakfast_utc, [_, _]}, {^dinner_utc, [_]}] =
               Tracking.upcoming(ctx.patient, ~U[2026-09-28 12:00:00Z])

      # Past the one-hour tolerance, breakfast no longer shows up.
      assert [{^dinner_utc, [_]}] = Tracking.upcoming(ctx.patient, ~U[2026-09-28 14:30:00Z])

      assert [{@breakfast_utc, [_, _]}] =
               Tracking.upcoming(ctx.patient, ~U[2026-09-28 12:00:00Z], 2)
    end
  end

  describe "mark_taken/2 and get_dose!/2" do
    test "records the time and removes the dose from upcoming", ctx do
      [dose] = Tracking.generate_doses_for_day(ctx.patient, @date)
      now = ~U[2026-09-28 13:05:00Z]

      assert {:ok, %{taken_at: ^now}} = Tracking.mark_taken(dose, now)
      assert [] = Tracking.upcoming(ctx.patient, now)
      assert Tracking.get_dose!(ctx.patient, dose.id).taken_at == now
    end

    test "get_dose!/2 only finds the patient's own doses", ctx do
      [dose] = Tracking.generate_doses_for_day(ctx.patient, @date)

      assert_raise Ecto.NoResultsError, fn ->
        Tracking.get_dose!(patient_fixture(), dose.id)
      end
    end
  end

  describe "adherence/4" do
    test "counts taken, missed and pending doses", ctx do
      Tracking.ensure_doses(ctx.patient, @date, ~D[2026-09-30])
      [first] = Tracking.list_doses_for_day(ctx.patient, @date)
      {:ok, _} = Tracking.mark_taken(first, ~U[2026-09-28 13:05:00Z])

      # September 30 at 06:00 local: that day's dose is still pending.
      now = ~U[2026-09-30 12:00:00Z]
      summary = Tracking.adherence(ctx.patient, @date, ~D[2026-09-30], now)

      assert %{expected: 2, taken: 1, missed: 1, pending: 1, percentage: 50} = summary
      assert length(summary.doses) == 3
    end

    test "returns zeros when there is nothing to count" do
      assert %{expected: 0, taken: 0, missed: 0, pending: 0, percentage: 0, doses: []} =
               Tracking.adherence(patient_fixture(), @date, @date, ~U[2026-09-30 12:00:00Z])
    end
  end
end
