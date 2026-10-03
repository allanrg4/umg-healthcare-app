defmodule UmgHealthcareWeb.Doctor.RenewalAlertController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Tracking.Scheduler
  alias UmgHealthcare.Treatments

  def index(conn, _params) do
    today = Scheduler.today(DateTime.utc_now())
    doctor = conn.assigns.current_scope.user

    render(conn, :index, today: today, alerts: Treatments.due_for_renewal(doctor, today))
  end

  def renew(conn, %{"id" => id}) do
    prescription = Treatments.get_prescription!(id)

    conn =
      if prescription.doctor_id == conn.assigns.current_scope.user.id do
        {:ok, _prescription} = Treatments.renew_prescription(prescription)
        put_flash(conn, :info, "Receta marcada como renovada.")
      else
        put_flash(conn, :error, "Solo el médico que la emitió puede renovar esta receta.")
      end

    redirect(conn, to: ~p"/doctor/alerts")
  end
end
