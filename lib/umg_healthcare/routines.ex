defmodule UmgHealthcare.Routines do
  @moduledoc "Daily activities of a patient. Doses are scheduled relative to them."

  import Ecto.Query, warn: false

  alias UmgHealthcare.Patients.Patient
  alias UmgHealthcare.Repo
  alias UmgHealthcare.Routines.Activity

  def list_activities(%Patient{id: patient_id}) do
    Activity
    |> where(patient_id: ^patient_id)
    |> order_by(asc: :time_of_day, asc: :name)
    |> Repo.all()
  end

  def get_activity!(%Patient{id: patient_id}, id) do
    Repo.get_by!(Activity, id: id, patient_id: patient_id)
  end

  def create_activity(%Patient{id: patient_id}, attrs) do
    %Activity{patient_id: patient_id}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  # Fails with a changeset if a prescription still uses the activity.
  def delete_activity(%Activity{} = activity) do
    activity
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.foreign_key_constraint(:name,
      name: :dose_schedules_activity_id_fkey,
      message: "is used by a prescription"
    )
    |> Repo.delete()
  end

  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end
end
