require "grape"
require "grape-swagger"
require_relative "./i_v1"

class Server < Grape::API
  # Public endpoint to check if app is online
  get :ping do
    content_type "text/plain"
    body "PONG"
  end
  # Private API version 1 endpoints
  mount APIv1

  # swagger docs must be at the end of the class
  add_swagger_documentation(
    hide_documentation_path: true,
    api_version: "v1",
    info: {
      title: "GOV.UK Forms API",
      description: "Core Forms management API"
    }
  )
end