Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "/up" => "rails/health#show", as: :rails_health_check

  get "/security.txt" => redirect("https://vdp.cabinetoffice.gov.uk/.well-known/security.txt")
  get "/.well-known/security.txt" => redirect("https://vdp.cabinetoffice.gov.uk/.well-known/security.txt")

  scope "api/v2", as: "api_v2" do
    resources :forms, controller: "api/v2/forms", only: %i[index show] do
      get "/:tag", to: "api/v2/form_documents#show", as: :document, constraints: { tag: /draft|live|archived/ }
    end

    resources :form_documents, path: "form-documents", controller: "api/v2/form_documents", only: %i[index] do
    end
  end

  scope "api/v1" do
    resources :forms, controller: "api/v1/forms" do
      member do
        get "/draft", to: "api/v1/forms#show_draft"
        get "/live", to: "api/v1/forms#show_live"
        get "/archived", to: "api/v1/forms#show_archived"
        post "/make-live", to: "api/v1/forms#make_live"
        post "/archive", to: "api/v1/forms#archive"
      end

      resources :pages, controller: "api/v1/pages", param: :page_id do
        member do
          resources :conditions, controller: "api/v1/conditions", param: :condition_id
        end
      end

      put "/pages/:page_id/down", to: "api/v1/pages#move_down", as: :move_page_down
      put "/pages/:page_id/up", to: "api/v1/pages#move_up", as: :move_page_up
    end

    resources :access_tokens, path: "access-tokens", controller: "api/v1/access_tokens", only: %i[index create], param: :token_id do
      member do
        put "/deactivate", to: "api/v1/access_tokens#deactivate"
      end
      collection do
        get "/caller-identity", to: "api/v1/access_tokens#caller_identity", as: :show_details_for
      end
    end

    scope :reports do
      get "/features", to: "api/v1/reports#features"
      get "/selection-questions-summary", to: "api/v1/reports#selection_questions_summary"
      get "/selection-questions-with-autocomplete", to: "api/v1/reports#selection_questions_with_autocomplete"
      get "/selection-questions-with-radios", to: "api/v1/reports#selection_questions_with_radios"
      get "/selection-questions-with-checkboxes", to: "api/v1/reports#selection_questions_with_checkboxes"
    end
  end
end
