require "grape"
require "grape-swagger"

class Server < Grape::API
  version "v1", using: :path, vendor: "forms"
  format :json
  prefix :api
  
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!(e, 400)
  end

  rescue_from :all do |e|
    Sentry.capture_exception(e)
    error! e.message, 500
  end

  before do
    @database = Database.existing_database
  end

  after do
    @database.disconnect
  end

  resource :forms do
    desc "Return all forms."
    get do
      repository = Repositories::FormsRepository.new(@database)
      repository.get_all
    end

    desc "Create a form."
    params do
      requires :name, type: String, desc: "Form name."
      requires :submission_email, type: String, desc: "Submission email."
    end
    post do
      repository = Repositories::FormsRepository.new(@database)
      id = repository.create(params[:name], params[:submission_email])
      {id: id}
    end

    route_param :form_id do
      desc "Read a form."
      get do
        repository = Repositories::FormsRepository.new(@database)
        repository.get(params[:form_id])
      end

      desc "Update a form."
      params do
        requires :name, type: String, desc: "Form name."
        requires :submission_email, type: String, desc: "Submission email."
      end
      put do
        repository = Repositories::FormsRepository.new(@database)
        repository.update(params[:form_id], params[:name], params[:submission_email])

        { success: true }
      end

      desc "Delete a form."
      delete do
        repository = Repositories::FormsRepository.new(@database)
        repository.delete(params[:form_id])
        { success: true }
      end

      resource :pages do
        desc "Return all pages for the form"
        get do
          repository = Repositories::PagesRepository.new(@database)
          repository.get_pages_in_form(params[:form_id])
        end

        desc "Create a new page."
        params do
          requires :question_text, type: String, desc: "Question text"
          optional :question_short_name, type: String, desc: "Question short name."
          optional :hint_text, type: String, desc: "Hint text"
          requires :answer_type, type: String,
                                 values: %w[single_line address date email national_insurance_number phone_number], desc: "Answer type"
        end
        post do
          repository = Repositories::PagesRepository.new(@database)
          id = repository.create(
            params[:form_id], 
            params[:question_text], 
            params[:question_short_name], 
            params[:hint_text], 
            params[:answer_type]
          )
          {id: id}
        end

        route_param :page_id do
          desc "Get a page."
          get do
            repository = Repositories::PagesRepository.new(@database)
            page = repository.get(params[:page_id])
            if page.nil?
              error! :not_found, 404
            end
            page
          end

          desc "Update a page."
          params do
            requires :question_text, type: String, desc: "Question text"
            optional :question_short_name, type: String, desc: "Question short name."
            optional :hint_text, type: String, desc: "Hint text"
            requires :answer_type, type: String,
                                   values: %w[single_line address date email national_insurance_number phone_number], desc: "Answer type"
          end
          put do
            repository = Repositories::PagesRepository.new(@database)
            updated_pages = repository.update(
              params[:page_id], 
              params[:question_text], 
              params[:question_short_name], 
              params[:hint_text], 
              params[:answer_type]
            )
            if updated_pages == 0
              error! :not_found, 404
            end
            {success: true}
          end

          desc "Delete a page."
          delete do
            repository = Repositories::PagesRepository.new(@database)
            deleted_pages = repository.delete(params[:page_id])
            if deleted_pages == 0
              error! :not_found, 404
            end
            {success: true}
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
