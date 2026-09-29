defmodule UmgHealthcare.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UmgHealthcareWeb.Telemetry,
      UmgHealthcare.Repo,
      {DNSCluster, query: Application.get_env(:umg_healthcare, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UmgHealthcare.PubSub},
      # Start a worker by calling: UmgHealthcare.Worker.start_link(arg)
      # {UmgHealthcare.Worker, arg},
      # Start to serve requests, typically the last entry
      UmgHealthcareWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UmgHealthcare.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UmgHealthcareWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
