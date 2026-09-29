defmodule UmgHealthcareWeb.UserLive.RegistrationTest do
  use UmgHealthcareWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import UmgHealthcare.AccountsFixtures

  alias UmgHealthcare.Accounts

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Crear una cuenta"
      assert html =~ "Inicia sesión"
      assert html =~ "Nombre completo"
      assert html =~ "Contraseña"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "short"})

      assert result =~ "Crear una cuenta"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  describe "register user" do
    test "creates the account and redirects to login", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")
      email = unique_user_email()

      form =
        form(lv, "#registration_form",
          user: %{
            full_name: "Dra. María Ruiz",
            email: email,
            password: valid_user_password(),
            role: "doctor"
          }
        )

      {:ok, _lv, html} = form |> render_submit() |> follow_redirect(conn, ~p"/users/log-in")

      assert html =~ "Cuenta creada"

      user = Accounts.get_user_by_email(email)
      assert user.full_name == "Dra. María Ruiz"
      assert user.role == :doctor
      assert user.confirmed_at
      assert Accounts.get_user_by_email_and_password(email, valid_user_password())
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")
      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{
            "full_name" => "Otra Persona",
            "email" => user.email,
            "password" => valid_user_password(),
            "role" => "patient"
          }
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end
end
