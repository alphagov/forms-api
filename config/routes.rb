Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get :ping, controller: :heartbeat

  # Defines the root path route ("/")
  # root "articles#index"
  scope "api/v1" do
    resources :forms, controller: "api/v1/forms" do
      resources :pages, controller: "api/v1/pages" do
        put "/down", to: "api/v1/pages#move_down"
        put "/up", to: "api/v1/pages#move_up"
      end
    end
  end
end
