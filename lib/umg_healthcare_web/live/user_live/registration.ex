defmodule UmgHealthcareWeb.UserLive.Registration do
  use UmgHealthcareWeb, :live_view

  alias UmgHealthcare.Accounts
  alias UmgHealthcare.Accounts.User
  alias UmgHealthcare.Patients

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto mt-6 max-w-sm space-y-4 rounded-box border border-base-300 bg-base-100 p-8 shadow-sm">
        <div class="text-center">
          <.header>
            Crear una cuenta
            <:subtitle>
              ¿Ya tienes cuenta?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-primary hover:underline">
                Inicia sesión
              </.link>
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:full_name]}
            type="text"
            label="Nombre completo"
            autocomplete="name"
            required
            phx-mounted={JS.focus()}
          />
          <.input
            field={@form[:email]}
            type="email"
            label="Correo electrónico"
            autocomplete="username"
            required
          />
          <.input
            field={@form[:password]}
            type="password"
            label="Contraseña"
            autocomplete="new-password"
            required
          />
          <.input
            field={@form[:role]}
            type="select"
            label="Soy"
            options={[{"Paciente", "patient"}, {"Médico", "doctor"}]}
          />

          <.button phx-disable-with="Creando cuenta..." variant="primary" class="w-full">
            Crear cuenta
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: %User{}}}} = socket) do
    {:ok, redirect(socket, to: UmgHealthcareWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        create_profile(user)

        {:noreply,
         socket
         |> put_flash(:info, "Cuenta creada. Ahora puedes iniciar sesión.")
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  # Patients need a profile from the start; doctors do not.
  defp create_profile(%User{role: :patient} = user) do
    {:ok, _patient} = Patients.create_patient(user)
  end

  defp create_profile(_user), do: :ok

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset, as: "user"))
  end
end
