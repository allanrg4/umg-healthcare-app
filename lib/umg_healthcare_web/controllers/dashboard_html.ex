defmodule UmgHealthcareWeb.DashboardHTML do
  use UmgHealthcareWeb, :html

  alias UmgHealthcare.Tracking.Scheduler

  embed_templates "dashboard_html/*"
end
