Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get :ping, controller: :heartbeat

  # Defines the root path route ("/")
  # root "articles#index"
  scope "api/v1" do
    resources :forms, controller: "api/v1/forms" do
      post "/make-live", on: :member, to: "api/v1/forms#make_live"
      resources :pages, controller: "api/v1/pages", param: :page_id do
      end
      put "/pages/:page_id/down", to: "api/v1/pages#move_down"
      put "/pages/:page_id/up", to: "api/v1/pages#move_up"
    end
  end
end
