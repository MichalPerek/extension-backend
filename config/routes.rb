Rails.application.routes.draw do
  # Mount Rodauth for authentication
  mount RodauthApp => "/auth"
  
  # API routes for Chrome extension
  namespace :api do
    # Profile endpoint
    get 'users/profile', to: 'users#profile'
    
    resources :conversations, only: [:index, :create, :show]
    resources :user_prompts, only: [:index, :show, :create, :update, :destroy]
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
