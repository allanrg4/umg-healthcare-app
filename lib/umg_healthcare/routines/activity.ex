defmodule UmgHealthcare.Routines.Activity do
  @moduledoc "A daily activity of a patient (breakfast, bedtime...) with its usual time."

  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :name, :string
    field :time_of_day, :time

    belongs_to :patient, UmgHealthcare.Patients.Patient

    timestamps(type: :utc_datetime)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:name, :time_of_day])
    |> validate_required([:name, :time_of_day])
    |> validate_length(:name, max: 60)
    |> unique_constraint(:name, name: :activities_patient_id_name_index)
  end
end
