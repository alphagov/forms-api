require "grape"
require "grape-swagger"

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
      @database[:forms].all
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

    route_param :form_id do
      desc "Read a form."
      get do
        @database[:forms].where(id: params[:form_id]).first
      end

      desc "Update a form."
      params do
        requires :name, type: String, desc: "Form name."
        requires :submission_email, type: String, desc: "Submission email."
      end
      put do
        @database[:forms].where(id: params[:form_id]).update(name: params[:name],
                                                             submission_email: params[:submission_email])

        { success: true }
      end

      desc "Delete a form."
      delete do
        @database[:forms].where(id: params[:form_id]).delete
        { success: true }
      end

      resource :pages do
        desc "Return all pages for the form"
        get do
          []
        end

        desc "Create a new page."
        params do
          requires :question_text, type: String, desc: "Question text"
          optional :question_short_name, type: String, desc: "Question short name."
          optional :hint_text, type: String, desc: "Hint text"
          requires :answer_type, type: Symbol,
                                 values: %i[single_line address date email national_insurance_number phone_number], desc: "Answer type"
        end
        post do
          {}
        end

        route_param :page_id do
          desc "Get a page."
          get do
            {}
          end

          desc "Update a page."
          params do
            requires :question_text, type: String, desc: "Question text"
            optional :question_short_name, type: String, desc: "Question short name."
            optional :hint_text, type: String, desc: "Hint text"
            requires :answer_type, type: Symbol,
                                   values: %i[single_line address date email national_insurance_number phone_number], desc: "Answer type"
          end
          put do
            {}
          end

          desc "Delete a page."
          delete do
            {}
          end
        end
      end
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
