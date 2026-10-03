defmodule UmgHealthcare.RoutinesFixtures do
  @moduledoc "Test helpers for the `UmgHealthcare.Routines` context."

  alias UmgHealthcare.Routines

  def activity_fixture(patient, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{name: "Desayuno", time_of_day: ~T[07:00:00]})
    {:ok, activity} = Routines.create_activity(patient, attrs)
    activity
  end
end
