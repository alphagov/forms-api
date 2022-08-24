require "grape"
require "grape-swagger"

class APIv1 < Grape::API
  version "v1", using: :path, vendor: "forms"
  format :json
  prefix :api

  helpers do
    def authenticate
      error!("Unauthorized", 401) unless headers["X-Api-Token"] == ENV["API_KEY"] && !ENV["API_KEY"].nil?
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!(e, 400)
  end

  rescue_from :all do |e|
    Sentry.capture_exception(e) unless ENV["SENTRY_DSN"].nil?

    error! e.message, 500
  end

  before do
    authenticate
    @database = Database.existing_database
  end

  after do
    @database.disconnect
  end

  resource :forms do
    desc "Return all forms by org."
    params do
      requires :org, type: String, desc: "Your org."
    end
    get do
      repository = Repositories::FormsRepository.new(@database)
      repository.get_by_org([params[:org]])
    end

    desc "Create a form."
    params do
      requires :name, type: String, desc: "Form name."
      requires :submission_email, type: String, desc: "Submission email."
      requires :org, type: String, desc: "Organization slug."
    end
    post do
      repository = Repositories::FormsRepository.new(@database)
      id = repository.create(params[:name], params[:submission_email], params[:org])
      { id: }
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
        pages = page_repository.get_pages_in_form(params[:form_id]).sort_by(&:id)
        form[:start_page] = (pages.first.id if pages.any?)
        form
      end

      desc "Update a form."
      params do
        requires :name, type: String, desc: "Form name."
        requires :submission_email, type: String, desc: "Submission email."
        requires :org, type: String, desc: "Organization slug."
        requires :live_at, type: String, desc: "Live at."
      end
      put do
        repository = Repositories::FormsRepository.new(@database)
        repository.update(params[:form_id], params[:name], params[:submission_email], params[:org], params[:live_at])
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
          repository.get_pages_in_form(params[:form_id]).sort_by(&:id).map(&:to_h)
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

          page = Domain::Page.new
          page.form_id = params[:form_id]
          page.question_text = params[:question_text]
          page.question_short_name = params[:question_short_name]
          page.hint_text = params[:hint_text]
          page.answer_type = params[:answer_type]

          id = repository.create(page)
          { id: }
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
            repository.get(params[:page_id]).to_h
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
            page = Domain::Page.new.tap do |p|
              p.id = params[:page_id]
              p.form_id = params[:form_id]
              p.question_text = params[:question_text]
              p.question_short_name = params[:question_short_name]
              p.hint_text = params[:hint_text]
              p.answer_type = params[:answer_type]
              p.next = params[:next]
            end

            repository.update(page)

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
end
