Rails.application.routes.draw do
devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }  
  
  get 'verify_otp', to: 'otp_verifications#new'
  post 'verify_otp', to: 'otp_verifications#create'


  namespace :superadmin do 
    get 'dashboard', to: 'dashboard#index' 
    patch 'approve/:id', to: 'dashboard#approve', as: 'approve_organization'
    patch 'inactive/:id', to: 'dashboard#inactive', as: 'inactive_organization'
  end

  namespace :admin do 
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  root ""
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
