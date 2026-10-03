defmodule UmgHealthcareWeb.ActivityController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Routines
  alias UmgHealthcare.Routines.Activity

  def index(conn, _params) do
    render(conn, :index, activities: Routines.list_activities(conn.assigns.patient))
  end

  def new(conn, _params) do
    render(conn, :new, form: to_form(Routines.change_activity(%Activity{})))
  end

  def create(conn, %{"activity" => params}) do
    case Routines.create_activity(conn.assigns.patient, params) do
      {:ok, _activity} ->
        conn
        |> put_flash(:info, "Actividad guardada.")
        |> redirect(to: ~p"/routine")

      {:error, changeset} ->
        render(conn, :new, form: to_form(changeset))
    end
  end

  def edit(conn, %{"id" => id}) do
    activity = Routines.get_activity!(conn.assigns.patient, id)
    render(conn, :edit, activity: activity, form: to_form(Routines.change_activity(activity)))
  end

  def update(conn, %{"id" => id, "activity" => params}) do
    activity = Routines.get_activity!(conn.assigns.patient, id)

    case Routines.update_activity(activity, params) do
      {:ok, _activity} ->
        conn
        |> put_flash(:info, "Actividad guardada.")
        |> redirect(to: ~p"/routine")

      {:error, changeset} ->
        render(conn, :edit, activity: activity, form: to_form(changeset))
    end
  end

  def delete(conn, %{"id" => id}) do
    activity = Routines.get_activity!(conn.assigns.patient, id)

    conn =
      case Routines.delete_activity(activity) do
        {:ok, _activity} ->
          put_flash(conn, :info, "Actividad eliminada.")

        {:error, _changeset} ->
          put_flash(conn, :error, "No se puede eliminar: una receta usa esta actividad.")
      end

    redirect(conn, to: ~p"/routine")
  end
end
