Rails.application.routes.draw do
  get 'relationships/create'
  get 'relationships/destroy'
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'password_resets/create'
  get 'password_resets/update'

  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

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
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: :edit
  resources :password_resets, only: %i(new create edit update)
  resources :microposts, only: %i(create destroy)
  resources :relationships, only: %i[create destroy]
end
