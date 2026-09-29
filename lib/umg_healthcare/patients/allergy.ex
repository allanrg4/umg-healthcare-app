defmodule UmgHealthcare.Patients.Allergy do
  @moduledoc "An allergy recorded for a patient."

  use Ecto.Schema
  import Ecto.Changeset

  schema "allergies" do
    field :substance, :string
    field :reaction, :string
    field :severity, Ecto.Enum, values: [:mild, :moderate, :severe]

    belongs_to :patient, UmgHealthcare.Patients.Patient

    timestamps(type: :utc_datetime)
  end

  def changeset(allergy, attrs) do
    allergy
    |> cast(attrs, [:substance, :reaction, :severity])
    |> validate_required([:substance, :severity])
    |> validate_length(:substance, max: 120)
  end
end
