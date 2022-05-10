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
        form_id: 1,
        form_name: "form name",
        user: "user@example.com"
      }
    end

    desc "Read a form."
    params do
      requires :formid, type: Integer, desc: "Form ID."
    end
    route_param :formid do
      get do
        {
          form_id: params[:formid],
          form_name: "form name",
          user: "user@example.com"
        }
      end
    end

    desc "Update a form."
    params do
      requires :id, type: String, desc: "Form ID."
      requires :status, type: String, desc: "Form data."
    end
    put ":id" do
      {
        form_id: params[:formid],
        form_name: "form name",
        user: "user@example.com"
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
