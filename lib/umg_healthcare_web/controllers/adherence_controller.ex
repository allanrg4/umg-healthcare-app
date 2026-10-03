defmodule UmgHealthcareWeb.AdherenceController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Tracking
  alias UmgHealthcare.Tracking.Scheduler

  def show(conn, _params) do
    patient = conn.assigns.patient
    now = DateTime.utc_now()
    today = Scheduler.today(now)

    Tracking.ensure_doses(patient, Date.add(today, -29), today)

    render(conn, :show,
      now: now,
      week: Tracking.adherence(patient, Date.add(today, -6), today, now),
      month: Tracking.adherence(patient, Date.add(today, -29), today, now)
    )
  end
end
