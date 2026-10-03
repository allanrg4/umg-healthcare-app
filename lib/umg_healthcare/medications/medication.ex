defmodule UmgHealthcare.Medications.Medication do
  @moduledoc "A medication from the hospital catalog."

  use Ecto.Schema
  import Ecto.Changeset

  schema "medications" do
    field :name, :string
    field :presentation, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(medication, attrs) do
    medication
    |> cast(attrs, [:name, :presentation])
    |> validate_required([:name])
    |> validate_length(:name, max: 120)
    |> unique_constraint(:name)
  end
end
