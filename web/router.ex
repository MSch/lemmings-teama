defmodule Lemmings.Router do
  use Lemmings.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/", Lemmings do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Lemmings do
    pipe_through :api
    get "/fb-webhook", FbController, :verify
    post "/fb-webhook", FbController, :webhook
  end
end
