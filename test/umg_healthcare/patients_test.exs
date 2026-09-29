defmodule UmgHealthcare.PatientsTest do
  use UmgHealthcare.DataCase, async: true

  import UmgHealthcare.AccountsFixtures
  import UmgHealthcare.PatientsFixtures

  alias UmgHealthcare.Patients

  describe "patients" do
    test "create_patient/2 links the profile to the user" do
      user = patient_user_fixture()

      assert {:ok, patient} = Patients.create_patient(user, %{phone: "5555-1234"})
      assert patient.user_id == user.id
      assert Patients.get_patient_for_user!(user).id == patient.id
      assert Patients.get_patient!(patient.id).user.full_name == user.full_name
    end

    test "a user can have only one profile" do
      user = patient_user_fixture()
      patient_fixture(user: user)

      assert {:error, changeset} = Patients.create_patient(user, %{})
      assert %{user_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "update_patient/2 changes birth_date and phone" do
      patient = patient_fixture()

      assert {:ok, patient} =
               Patients.update_patient(patient, %{birth_date: ~D[1990-05-20], phone: "1234"})

      assert patient.birth_date == ~D[1990-05-20]
      assert patient.phone == "1234"
    end

    test "list_patients/1 filters by name, case-insensitive, ordered by name" do
      patient_fixture(full_name: "Carlos Pérez")
      patient_fixture(full_name: "Ana López")

      assert [%{user: %{full_name: "Ana López"}}, %{user: %{full_name: "Carlos Pérez"}}] =
               Patients.list_patients()

      assert [%{user: %{full_name: "Carlos Pérez"}}] = Patients.list_patients("carlos")
      assert [] = Patients.list_patients("nadie")
    end
  end

  describe "allergies" do
    test "create_allergy/2 and list_allergies/1" do
      patient = patient_fixture()

      assert {:ok, allergy} =
               Patients.create_allergy(patient, %{substance: "Penicilina", severity: :severe})

      assert [%{id: id, substance: "Penicilina", severity: :severe}] =
               Patients.list_allergies(patient)

      assert id == allergy.id
    end

    test "create_allergy/2 requires substance and severity" do
      assert {:error, changeset} = Patients.create_allergy(patient_fixture(), %{})
      assert %{substance: ["can't be blank"], severity: ["can't be blank"]} = errors_on(changeset)
    end

    test "allergies belong to one patient" do
      patient = patient_fixture()
      other = patient_fixture()
      allergy = allergy_fixture(other)

      assert [] = Patients.list_allergies(patient)

      assert_raise Ecto.NoResultsError, fn ->
        Patients.get_allergy!(patient, allergy.id)
      end
    end

    test "delete_allergy/1 removes it" do
      patient = patient_fixture()
      allergy = allergy_fixture(patient)

      assert {:ok, _} = Patients.delete_allergy(allergy)
      assert [] = Patients.list_allergies(patient)
    end
  end
end
