defmodule UmgHealthcareWeb.DashboardController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Tracking
  alias UmgHealthcare.Tracking.Scheduler

  @backfill_days 7

  def index(conn, _params) do
    patient = conn.assigns.patient
    now = DateTime.utc_now()
    today = Scheduler.today(now)

    # Doses for the last days (in case the app was not opened), today and tomorrow.
    Tracking.ensure_doses(patient, Date.add(today, -@backfill_days), Date.add(today, 1))

    render(conn, :index,
      now: now,
      today: today,
      upcoming: Tracking.upcoming(patient, now),
      today_doses: Tracking.list_doses_for_day(patient, today)
    )
  end
end
