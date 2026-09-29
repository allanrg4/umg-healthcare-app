defmodule UmgHealthcareApp.Repo do
  use Ecto.Repo,
    otp_app: :umg_healthcare_app,
    adapter: Ecto.Adapters.Postgres
end
