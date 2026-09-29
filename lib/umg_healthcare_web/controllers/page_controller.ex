defmodule UmgHealthcareWeb.PageController do
  use UmgHealthcareWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
