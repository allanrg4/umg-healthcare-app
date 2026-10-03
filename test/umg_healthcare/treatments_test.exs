defmodule UmgHealthcare.TreatmentsTest do
  use UmgHealthcare.DataCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures
  import UmgHealthcare.TreatmentsFixtures

  alias UmgHealthcare.{Routines, Treatments}

  setup do
    patient = patient_fixture()
    %{patient: patient, doctor: doctor_user_fixture(), activity: activity_fixture(patient)}
  end

  describe "create_prescription/3" do
    test "creates the prescription with its daily schedules", ctx do
      medication = medication_fixture(name: "Amoxicilina")

      assert {:ok, prescription} =
               Treatments.create_prescription(ctx.patient, ctx.doctor, %{
                 medication_id: medication.id,
                 dose: "1 cápsula",
                 instructions: "Con agua",
                 starts_on: ~D[2026-09-28],
                 duration_days: 7,
                 dose_schedules: [%{activity_id: ctx.activity.id, offset_minutes: 30}]
               })

      assert prescription.status == :active
      assert prescription.doctor_id == ctx.doctor.id

      loaded = Treatments.get_prescription!(prescription.id)
      assert loaded.medication.name == "Amoxicilina"
      assert [%{offset_minutes: 30, activity: %{name: "Desayuno"}}] = loaded.dose_schedules
    end

    test "requires at least one schedule and a positive duration", ctx do
      assert {:error, changeset} =
               Treatments.create_prescription(ctx.patient, ctx.doctor, %{
                 medication_id: medication_fixture().id,
                 dose: "1",
                 starts_on: ~D[2026-09-28],
                 duration_days: 0,
                 dose_schedules: []
               })

      errors = errors_on(changeset)
      assert errors.duration_days == ["must be greater than 0"]
      assert errors.dose_schedules == ["can't be blank"]
    end

    test "only doctors can prescribe", ctx do
      assert_raise FunctionClauseError, fn ->
        Treatments.create_prescription(ctx.patient, patient_user_fixture(), %{})
      end
    end
  end

  describe "current and past" do
    test "list_current/2 and list_past/2 split by end date and status", ctx do
      today = ~D[2026-09-28]

      current =
        prescription_fixture(ctx.patient, ctx.doctor,
          starts_on: ~D[2026-09-25],
          duration_days: 10
        )

      expired =
        prescription_fixture(ctx.patient, ctx.doctor, starts_on: ~D[2026-09-01], duration_days: 5)

      completed =
        prescription_fixture(ctx.patient, ctx.doctor, starts_on: today, duration_days: 30)

      {:ok, _} = Treatments.complete_prescription(completed)

      assert [%{id: current_id}] = Treatments.list_current(ctx.patient, today)
      assert current_id == current.id

      past_ids = ctx.patient |> Treatments.list_past(today) |> Enum.map(& &1.id) |> Enum.sort()
      assert past_ids == Enum.sort([expired.id, completed.id])
    end
  end

  describe "renewal" do
    test "due_for_renewal/3 lists the doctor's active prescriptions ending soon", ctx do
      today = ~D[2026-09-28]

      soon =
        prescription_fixture(ctx.patient, ctx.doctor, starts_on: ~D[2026-09-24], duration_days: 7)

      overdue =
        prescription_fixture(ctx.patient, ctx.doctor, starts_on: ~D[2026-09-01], duration_days: 5)

      _later = prescription_fixture(ctx.patient, ctx.doctor, starts_on: today, duration_days: 30)

      _other_doctor =
        prescription_fixture(ctx.patient, doctor_user_fixture(),
          starts_on: today,
          duration_days: 2
        )

      ids = ctx.doctor |> Treatments.due_for_renewal(today) |> Enum.map(& &1.id)
      assert ids == [overdue.id, soon.id]

      assert [%{patient: %{user: %{full_name: "Ana López"}}, medication: %{}} | _] =
               Treatments.due_for_renewal(ctx.doctor, today)
    end

    test "renew_prescription/1 takes it out of the alerts", ctx do
      today = ~D[2026-09-28]

      soon =
        prescription_fixture(ctx.patient, ctx.doctor, starts_on: ~D[2026-09-27], duration_days: 2)

      assert {:ok, %{status: :renewed}} = Treatments.renew_prescription(soon)
      assert [] = Treatments.due_for_renewal(ctx.doctor, today)
    end
  end

  describe "active_schedules_for/2" do
    test "returns schedules of prescriptions active on that date, with preloads", ctx do
      dinner = activity_fixture(ctx.patient, name: "Cena", time_of_day: ~T[19:00:00])

      prescription_fixture(ctx.patient, ctx.doctor,
        starts_on: ~D[2026-09-28],
        duration_days: 3,
        activity: ctx.activity
      )

      prescription_fixture(ctx.patient, ctx.doctor,
        starts_on: ~D[2026-10-10],
        duration_days: 3,
        activity: dinner
      )

      assert [schedule] = Treatments.active_schedules_for(ctx.patient, ~D[2026-09-29])
      assert schedule.activity.name == "Desayuno"
      assert schedule.prescription.medication.name

      assert [] = Treatments.active_schedules_for(ctx.patient, ~D[2026-10-01])
      assert [] = Treatments.active_schedules_for(patient_fixture(), ~D[2026-09-29])
    end
  end

  test "an activity used by a prescription cannot be deleted", ctx do
    prescription_fixture(ctx.patient, ctx.doctor, activity: ctx.activity)

    assert {:error, changeset} = Routines.delete_activity(ctx.activity)
    assert %{name: ["is used by a prescription"]} = errors_on(changeset)
    assert [_] = Routines.list_activities(ctx.patient)
  end
end
