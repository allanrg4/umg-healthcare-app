defmodule UmgHealthcare.Patients.Patient do
  @moduledoc "Patient profile. The name and email live in the linked user."

  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :birth_date, :date
    field :phone, :string

    belongs_to :user, UmgHealthcare.Accounts.User
    has_many :allergies, UmgHealthcare.Patients.Allergy

    timestamps(type: :utc_datetime)
  end

  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:birth_date, :phone])
    |> validate_length(:phone, max: 30)
    |> unique_constraint(:user_id)
  end
end
