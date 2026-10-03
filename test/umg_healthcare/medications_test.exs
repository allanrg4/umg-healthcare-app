defmodule UmgHealthcare.MedicationsTest do
  use UmgHealthcare.DataCase, async: true

  import UmgHealthcare.MedicationsFixtures

  alias UmgHealthcare.Medications

  test "create_medication/1 requires a unique name" do
    assert {:ok, medication} =
             Medications.create_medication(%{name: "Ibuprofeno", presentation: "tableta 400 mg"})

    assert Medications.get_medication!(medication.id).name == "Ibuprofeno"

    assert {:error, changeset} = Medications.create_medication(%{name: "Ibuprofeno"})
    assert %{name: ["has already been taken"]} = errors_on(changeset)

    assert {:error, changeset} = Medications.create_medication(%{})
    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end

  test "list_medications/0 orders by name" do
    medication_fixture(name: "Paracetamol")
    medication_fixture(name: "Amoxicilina")

    assert [%{name: "Amoxicilina"}, %{name: "Paracetamol"}] = Medications.list_medications()
  end

  test "seed_catalog/0 can run many times without duplicating" do
    Medications.seed_catalog()
    count = length(Medications.list_medications())
    assert count > 0

    Medications.seed_catalog()
    assert length(Medications.list_medications()) == count
  end
end
