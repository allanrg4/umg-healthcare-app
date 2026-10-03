defmodule UmgHealthcareWeb.PageController do
  use UmgHealthcareWeb, :controller

  alias UmgHealthcare.Accounts.User

  # Visitors see the landing page; logged-in users go to their own home page.
  def home(conn, _params) do
    case conn.assigns[:current_scope] do
      %{user: %User{role: :doctor}} -> redirect(conn, to: ~p"/doctor/patients")
      %{user: %User{role: :patient}} -> redirect(conn, to: ~p"/dashboard")
      _ -> render(conn, :home)
    end
  end
end
