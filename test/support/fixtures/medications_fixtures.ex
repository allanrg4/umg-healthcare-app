defmodule UmgHealthcare.MedicationsFixtures do
  @moduledoc "Test helpers for the `UmgHealthcare.Medications` context."

  alias UmgHealthcare.Medications

  def medication_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Medicamento #{System.unique_integer([:positive])}",
        presentation: "tableta 500 mg"
      })

    {:ok, medication} = Medications.create_medication(attrs)
    medication
  end
end
