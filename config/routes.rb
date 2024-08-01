Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'password_resets/create'
  get 'password_resets/update'

  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  get "products/index"
  get "products/show"
  get "products/new"
  get "products/edit"

  get "demo_partials/new"
  get "demo_partials/edit"

  get "static_pages/home"
  get "static_pages/help"

  # Định nghĩa các route cho users
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users

  # Định nghĩa các route cho products
  resources :products

  # Định nghĩa root path
  root "static_pages#home" # Hoặc trang nào bạn muốn đặt làm trang chính


  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :account_activations, only: :edit
  resources :password_resets, only: %i(new create edit update)
end
