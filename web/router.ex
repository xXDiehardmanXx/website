defmodule SignDict.Router do
  use SignDict.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SignDict.Plug.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug SignDict.Plug.CurrentUser
  end

  pipeline :auth do
    plug Guardian.Plug.EnsureAuthenticated,
         handler: SignDict.GuardianErrorHandler
  end

  scope "/", SignDict do
    pipe_through [:browser, :browser_session]

    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    get "/", PageController, :index
  end

  # Backend functions. Only accessible to logged in admin users.
  scope "/backend", SignDict.Backend, as: :backend do
    pipe_through [:browser, :browser_session, :auth]
    # TODO: insert plug for admin users only here

    resources "/videos", VideoController
  end
end
