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

  def delete_activity(%Activity{} = activity), do: Repo.delete(activity)

  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end
end
