defmodule HelloWeb.Router do
  use HelloWeb, :router

  defp put_missed_security_headers(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header(
      "strict-transport-security",
      "max-age=31536000; includeSubDomains; preload"
    )
    |> Plug.Conn.put_resp_header("x-frame-options", "SAMEORIGIN")
    |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
  end

  defp dashboard_basic_auth(conn, _opts) do
    if Application.get_env(:hello, :env) == :prod do
      opts = Application.get_env(:hello, :dashboard_auth, [])
      Plug.BasicAuth.basic_auth(conn, opts)
    else
      conn
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HelloWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_missed_security_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protect_dashboard do
    plug :dashboard_basic_auth
  end

  scope "/", HelloWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/up/", UpController, :index
    get "/up/databases", UpController, :databases

    get "/tags/:tag", PageController, :tags
    get "/posts/:slug", PageController, :show
  end

  # LiveDashboard: in dev/test no auth; in prod protected by HTTP Basic Auth.
  # Set DASHBOARD_USERNAME and DASHBOARD_PASSWORD in production.
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:browser, :protect_dashboard]
    live_dashboard "/dashboard", metrics: HelloWeb.Telemetry
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:new, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HelloWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
