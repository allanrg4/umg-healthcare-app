defmodule UmgHealthcare.Medications do
  @moduledoc "Catalog of medications doctors can prescribe."

  import Ecto.Query, warn: false

  alias UmgHealthcare.Medications.Medication
  alias UmgHealthcare.Repo

  @catalog [
    {"Amoxicilina", "cápsula 500 mg"},
    {"Ibuprofeno", "tableta 400 mg"},
    {"Paracetamol", "tableta 500 mg"},
    {"Losartán", "tableta 50 mg"},
    {"Metformina", "tableta 850 mg"},
    {"Omeprazol", "cápsula 20 mg"},
    {"Atorvastatina", "tableta 20 mg"},
    {"Salbutamol", "inhalador 100 mcg"},
    {"Levotiroxina", "tableta 50 mcg"},
    {"Loratadina", "tableta 10 mg"}
  ]

  def list_medications do
    Medication |> order_by(asc: :name) |> Repo.all()
  end

  def get_medication!(id), do: Repo.get!(Medication, id)

  def create_medication(attrs) do
    %Medication{}
    |> Medication.changeset(attrs)
    |> Repo.insert()
  end

  # Inserts the base catalog. Safe to run as many times as you want.
  def seed_catalog do
    now = DateTime.utc_now(:second)

    rows =
      for {name, presentation} <- @catalog do
        %{name: name, presentation: presentation, inserted_at: now, updated_at: now}
      end

    Repo.insert_all(Medication, rows, on_conflict: :nothing, conflict_target: :name)
    :ok
  end
end
