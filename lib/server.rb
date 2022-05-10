require "grape"
require "grape-swagger"

class Server < Grape::API
  version "v1", using: :path, vendor: "forms"
  format :json
  prefix :api

  resource :forms do
    desc "Create a form."
    params do
      requires :form, type: String, desc: "Form data."
    end
    post do
      {
        id: 1,
        name: "form name",
        submission_email: "user@example.com"
      }
    end

    desc "Read a form."
    params do
      requires :id, type: Integer, desc: "Form ID."
    end
    route_param :id do
      get do
        {
          id: params[:id],
          name: "form name",
          submission_email: "user@example.com"
        }
      end
    end

    desc "Update a form."
    params do
      requires :id, type: String, desc: "Form ID."
      requires :data, type: String, desc: "Form data."
    end
    put ":id" do
      {
        id: id,
        name: "form name",
        submission_email: "user@example.com"
      }
    end

    desc "Delete a status."
    params do
      requires :id, type: String, desc: "Form ID."
    end
    delete ":id" do
      "Deleted."
    end
  end

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
