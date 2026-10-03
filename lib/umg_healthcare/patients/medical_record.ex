defmodule UmgHealthcare.Patients.MedicalRecord do
  @moduledoc "A clinical history entry: consultation, diagnosis or test result."

  use Ecto.Schema
  import Ecto.Changeset

  schema "medical_records" do
    field :kind, Ecto.Enum, values: [:consultation, :diagnosis, :test_result]
    field :title, :string
    field :details, :string
    field :recorded_on, :date

    belongs_to :patient, UmgHealthcare.Patients.Patient
    belongs_to :doctor, UmgHealthcare.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:kind, :title, :details, :recorded_on])
    |> validate_required([:kind, :title, :recorded_on])
    |> validate_length(:title, max: 160)
  end
end
