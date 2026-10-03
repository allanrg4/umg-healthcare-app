defmodule UmgHealthcareWeb.Router do
  use UmgHealthcareWeb, :router

  import UmgHealthcareWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UmgHealthcareWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :patient do
    plug :require_authenticated_user
    plug :require_patient_user
  end

  pipeline :doctor do
    plug :require_authenticated_user
    plug :require_doctor_user
  end

  scope "/", UmgHealthcareWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Patient pages: require a logged-in user with the patient role.
  scope "/", UmgHealthcareWeb do
    pipe_through [:browser, :patient]

    get "/dashboard", DashboardController, :index
    post "/doses/:id/take", DoseController, :take
    get "/adherence", AdherenceController, :show
    resources "/routine", ActivityController, except: [:show]
  end

  # Doctor pages: require a logged-in user with the doctor role.
  scope "/doctor", UmgHealthcareWeb.Doctor do
    pipe_through [:browser, :doctor]

    resources "/patients", PatientController, only: [:index, :show] do
      resources "/allergies", AllergyController, only: [:create, :delete]
      resources "/medical_records", MedicalRecordController, only: [:create]
      resources "/prescriptions", PrescriptionController, only: [:new, :create]
    end

    patch "/prescriptions/:id/complete", PrescriptionController, :complete
  end

  # Other scopes may use custom stacks.
  # scope "/api", UmgHealthcareWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:umg_healthcare, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UmgHealthcareWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", UmgHealthcareWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{UmgHealthcareWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", UmgHealthcareWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{UmgHealthcareWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
