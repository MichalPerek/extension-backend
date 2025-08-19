Rails.application.routes.draw do
  # Mount Rodauth for authentication
  mount RodauthApp => "/auth"
  
  # API routes for Chrome extension
  namespace :api do
    # Profile endpoint
    get 'users/profile', to: 'users#profile'
    
    resources :conversations, only: [:index, :show, :update, :destroy] do
      collection do
        get 'stats'
        get 'session/:session_id', to: 'conversations#by_session'
      end
    end
    resources :user_prompts, only: [:index, :show, :create, :update, :destroy]
    
    # AI Processing routes
    namespace :ai do
      post 'process', to: 'processing#process_prompt'
      get 'models', to: 'processing#models'
      get 'available_models', to: 'processing#available_models'
      post 'test/:model_id', to: 'processing#test_model'
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
