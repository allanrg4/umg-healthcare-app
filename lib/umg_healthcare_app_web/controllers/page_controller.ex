defmodule UmgHealthcareAppWeb.PageController do
  use UmgHealthcareAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
