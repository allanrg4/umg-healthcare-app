defmodule UmgHealthcareWeb.PageController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Accounts.User

  # The root only redirects: each role has its own home page.
  def home(conn, _params) do
    case conn.assigns[:current_scope] do
      %{user: %User{role: :doctor}} -> redirect(conn, to: ~p"/doctor/patients")
      %{user: %User{role: :patient}} -> redirect(conn, to: ~p"/dashboard")
      _ -> redirect(conn, to: ~p"/users/log-in")
    end
  end
end
