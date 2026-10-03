defmodule UmgHealthcare.TreatmentsFixtures do
  @moduledoc "Test helpers for the `UmgHealthcare.Treatments` context."

  import UmgHealthcare.MedicationsFixtures
  import UmgHealthcare.RoutinesFixtures

  alias UmgHealthcare.Treatments

  # Active prescription with one daily schedule. Options: :activity, :medication,
  # :offset_minutes and any prescription field.
  def prescription_fixture(patient, doctor, attrs \\ %{}) do
    attrs = Map.new(attrs)
    {activity, attrs} = Map.pop_lazy(attrs, :activity, fn -> unique_activity(patient) end)
    {medication, attrs} = Map.pop_lazy(attrs, :medication, fn -> medication_fixture() end)
    {offset, attrs} = Map.pop(attrs, :offset_minutes, 0)

    attrs =
      Enum.into(attrs, %{
        medication_id: medication.id,
        dose: "1 tableta",
        starts_on: ~D[2026-09-28],
        duration_days: 7,
        dose_schedules: [%{activity_id: activity.id, offset_minutes: offset}]
      })

    {:ok, prescription} = Treatments.create_prescription(patient, doctor, attrs)
    Treatments.get_prescription!(prescription.id)
  end

  # Activity names are unique per patient, so each default activity gets its own name.
  defp unique_activity(patient) do
    activity_fixture(patient, name: "Actividad #{System.unique_integer([:positive])}")
  end
end
