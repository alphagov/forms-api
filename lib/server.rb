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
    Sentry.capture_exception(e) unless ENV["SENTRY_DSN"].nil?

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
      repository.fetch_all
    end

    desc "Create a form."
    params do
      requires :name, type: String, desc: "Form name."
      requires :submission_email, type: String, desc: "Submission email."
    end
    post do
      repository = Repositories::FormsRepository.new(@database)
      id = repository.create(params[:name], params[:submission_email])
      { id: id }
    end

    route_param :form_id do
      before do
        repository = Repositories::FormsRepository.new(@database)
        form = repository.get(params[:form_id])
        error! :not_found, 404 if form.nil?
      end

      desc "Read a form."
      get do
        repository = Repositories::FormsRepository.new(@database)
        page_repository = Repositories::PagesRepository.new(@database)

        form = repository.get(params[:form_id])
        pages = page_repository.get_pages_in_form(params[:form_id]).sort_by { |page| page[:id] }
        form[:start_page] = (pages.first[:id] if pages.any?)
        form
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
        before do
          repository = Repositories::FormsRepository.new(@database)
          form = repository.get(params[:form_id])
          error! :not_found, 404 if form.nil?
        end

        desc "Return all pages for the form"
        get do
          repository = Repositories::PagesRepository.new(@database)
          repository.get_pages_in_form(params[:form_id]).sort_by { |page| page[:id] }
        end

        desc "Create a new page."
        params do
          requires :question_text, type: String, desc: "Question text"
          optional :question_short_name, type: String, desc: "Question short name."
          optional :hint_text, type: String, desc: "Hint text"
          requires :answer_type, type: String,
                                 values: %w[single_line address date email national_insurance_number phone_number], desc: "Answer type"
          optional :next, type: String, desc: "The ID of the next page"
        end
        post do
          repository = Repositories::PagesRepository.new(@database)

          id = repository.create(
            params[:form_id],
            params[:question_text],
            params[:question_short_name],
            params[:hint_text],
            params[:answer_type],
            params[:next]
          )
          { id: id }
        end

        route_param :page_id do
          before do
            repository = Repositories::PagesRepository.new(@database)
            page = repository.get(params[:page_id])
            error! :not_found, 404 if page.nil?
          end

          desc "Get a page."
          get do
            repository = Repositories::PagesRepository.new(@database)
            repository.get(params[:page_id])
          end

          desc "Update a page."
          params do
            requires :question_text, type: String, desc: "Question text"
            optional :question_short_name, type: String, desc: "Question short name."
            optional :hint_text, type: String, desc: "Hint text"
            requires :answer_type, type: String,
                                   values: %w[single_line address date email national_insurance_number phone_number], desc: "Answer type"
            optional :next, type: String, desc: "The ID of the next page"
          end
          put do
            repository = Repositories::PagesRepository.new(@database)
            repository.update(
              params[:page_id],
              params[:question_text],
              params[:question_short_name],
              params[:hint_text],
              params[:answer_type],
              params[:next]
            )
            { success: true }
          end

          desc "Delete a page."
          delete do
            repository = Repositories::PagesRepository.new(@database)
            repository.delete(params[:page_id])
            { success: true }
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
