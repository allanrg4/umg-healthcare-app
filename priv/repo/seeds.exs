# Initial data. Runs with `mix ecto.setup` or `mix run priv/repo/seeds.exs`
# and is safe to run more than once.

UmgHealthcare.Medications.seed_catalog()

case UmgHealthcare.DemoData.load() do
  :ok -> IO.puts("Demo data loaded. Users and password are listed in the README.")
  :already_loaded -> IO.puts("Demo data was already loaded.")
end
