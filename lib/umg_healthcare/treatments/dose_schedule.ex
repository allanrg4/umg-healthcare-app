defmodule UmgHealthcare.Treatments.DoseSchedule do
  @moduledoc "One daily dose of a prescription, anchored to an activity plus an offset in minutes."

  use Ecto.Schema
  import Ecto.Changeset

  schema "dose_schedules" do
    field :offset_minutes, :integer, default: 0

    belongs_to :prescription, UmgHealthcare.Treatments.Prescription
    belongs_to :activity, UmgHealthcare.Routines.Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:activity_id, :offset_minutes])
    |> validate_required([:activity_id, :offset_minutes])
    |> validate_number(:offset_minutes,
      greater_than_or_equal_to: -720,
      less_than_or_equal_to: 720
    )
    |> assoc_constraint(:activity)
  end
end
