require "grape"
require "grape-swagger"
require "pry"

class Server < Grape::API
  version "v1", using: :path, vendor: "forms"
  format :json
  prefix :api

  before do
    @database = Database.existing_database
  end

  after do
    @database.disconnect
  end

  resource :forms do
    desc "Return all forms."
    get do
      [
        {
          id: 1,
          name: "form name",
          submission_email: "user@example.com"
        },
        {
          id: 2,
          name: "form name",
          submission_email: "user@example.com"
        },
        {
          id: 3,
          name: "form name",
          submission_email: "user@example.com"
        }
      ]
    end

    desc "Create a form."
    params do
      requires :name, type: String, desc: "Form name."
      requires :submission_email, type: String, desc: "Submission email."
    end
    post do
      repository = Repositories::ExampleRepository.new(@database)
      repository.test_query(params[:name], params[:submission_email])[:result]
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
      requires :name, type: String, desc: "Form name."
      requires :submission_email, type: String, desc: "Submission email."
    end
    put ":id" do
      {
        id: params[:id],
        name: params[:name],
        submission_email: params[:submission_email]
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
