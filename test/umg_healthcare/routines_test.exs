defmodule UmgHealthcare.RoutinesTest do
  use UmgHealthcare.DataCase, async: true

  import UmgHealthcare.PatientsFixtures
  import UmgHealthcare.RoutinesFixtures

  alias UmgHealthcare.Routines

  test "create_activity/2 and list_activities/1 ordered by time" do
    patient = patient_fixture()

    assert {:ok, _} =
             Routines.create_activity(patient, %{name: "Cena", time_of_day: ~T[19:30:00]})

    assert {:ok, _} =
             Routines.create_activity(patient, %{name: "Desayuno", time_of_day: ~T[07:00:00]})

    assert [%{name: "Desayuno"}, %{name: "Cena"}] = Routines.list_activities(patient)
  end

  test "create_activity/2 requires name and time" do
    assert {:error, changeset} = Routines.create_activity(patient_fixture(), %{})
    assert %{name: ["can't be blank"], time_of_day: ["can't be blank"]} = errors_on(changeset)
  end

  test "activity names are unique per patient" do
    patient = patient_fixture()
    activity_fixture(patient, name: "Desayuno")

    assert {:error, changeset} =
             Routines.create_activity(patient, %{name: "Desayuno", time_of_day: ~T[08:00:00]})

    assert %{name: ["has already been taken"]} = errors_on(changeset)

    # Another patient can use the same name.
    assert {:ok, _} =
             Routines.create_activity(patient_fixture(), %{
               name: "Desayuno",
               time_of_day: ~T[08:00:00]
             })
  end

  test "update_activity/2 changes the time" do
    activity = activity_fixture(patient_fixture())

    assert {:ok, activity} = Routines.update_activity(activity, %{time_of_day: ~T[07:30:00]})
    assert activity.time_of_day == ~T[07:30:00]
  end

  test "get_activity!/2 only finds the patient's own activities" do
    patient = patient_fixture()
    activity = activity_fixture(patient_fixture())

    assert_raise Ecto.NoResultsError, fn -> Routines.get_activity!(patient, activity.id) end
  end

  test "delete_activity/1 removes it" do
    patient = patient_fixture()
    activity = activity_fixture(patient)

    assert {:ok, _} = Routines.delete_activity(activity)
    assert [] = Routines.list_activities(patient)
  end
end
