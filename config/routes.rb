Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get :ping, controller: :heartbeat

  # Defines the root path route ("/")
  # root "articles#index"
  scope "api/v1" do
    resources :forms, controller: "api/v1/forms" do
      member do
        post "/make-live", to: "api/v1/forms#make_live"
        get "/live", to: "api/v1/forms#show_live"
        get "/draft", to: "api/v1/forms#show_draft"
      end

      resources :pages, controller: "api/v1/pages", param: :page_id
      put "/pages/:page_id/down", to: "api/v1/pages#move_down", as: :move_page_down
      put "/pages/:page_id/up", to: "api/v1/pages#move_up", as: :move_page_up
    end

    resources :access_tokens, path: "access-tokens", controller: "api/v1/access_tokens", only: %i[index create] do
      member do
        put "/deactivate", to: "api/v1/access_tokens#deactivate"
      end
      collection do
        get "/caller-identity", to: "api/v1/access_tokens#caller_identity", as: :show_details_for
      end
    end
  end
end
