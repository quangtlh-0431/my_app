Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "static_pages#home"
    get "static_pages/help", as: :help
    get  "/about",   to: "static_pages#about"
    get  "/contact", to: "static_pages#contact"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"

    delete "/logout", to: "sessions#destroy"

    resources :account_activations, only: %i(edit)
    resources :password_resets, only: %i(new create edit update)
    resources :users do
      resources :followings, only: :index
      resources :followers, only: :index
    end
    resources :relationships, only: [:create, :destroy]
    resources :microposts, only: %i(create destroy)
  end
end
