defmodule UmgHealthcare.Repo do
  use Ecto.Repo,
    otp_app: :umg_healthcare,
    adapter: Ecto.Adapters.Postgres
end
