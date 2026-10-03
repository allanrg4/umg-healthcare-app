defmodule UmgHealthcareWeb.DoseController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Tracking

  def take(conn, %{"id" => id}) do
    dose = Tracking.get_dose!(conn.assigns.patient, id)
    {:ok, _dose} = Tracking.mark_taken(dose, DateTime.utc_now())

    conn
    |> put_flash(:info, "Toma registrada.")
    |> redirect(to: ~p"/dashboard")
  end
end
