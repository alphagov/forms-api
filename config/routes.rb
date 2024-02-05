Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "/up" => "rails/health#show", as: :rails_health_check

  # TODO: Remove once infrastructure has been updated to use /up
  get :ping, controller: :heartbeat

  # Defines the root path route ("/")
  # root "articles#index"
  scope "api/v1" do
    resources :forms, controller: "api/v1/forms" do
      member do
        get "/draft", to: "api/v1/forms#show_draft"
        get "/live", to: "api/v1/forms#show_live"
        post "/make-live", to: "api/v1/forms#make_live"
        post "/archive", to: "api/v1/forms#archive"
      end

      collection do
        patch "/update-organisation-for-creator", to: "api/v1/forms#update_organisation_for_creator"
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
  end
end
