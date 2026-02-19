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
    # Req 1, 2, 5: Dashboard & Status Controls
    get 'dashboard', to: 'dashboard#index'
    patch 'toggle_booking', to: 'dashboard#toggle_booking'
    patch 'update_doctor_status', to: 'dashboard#update_doctor_status'
    patch 'appointments/:id/update_status', to: 'dashboard#update_status', as: :update_appt_status
    
    # Req 3: Booking Time & Prefix
    resources :booking_controls, only: [:index, :update]
    
    # Req 4: Reserved Tokens
    resources :reserved_tokens, only: [:index, :create, :destroy]
    
    # Req 7: Field Settings (Mandatory/Optional Fields)
    resources :field_settings, only: [:index] do
      collection { patch :update_all }
    end
    
    # Req 8: Notices for Patients
    resources :notices, only: [:index, :create, :destroy]
    
    # Req 6: Admin Profile (Edit Password)
    resource :profile, only: [:edit, :update]
  end

  # --- Patient Side Routes ---
  # Aa routes patients mate che jo QR scan karshe tyare vaprashe
  resources :appointments, only: [:new, :create, :show]


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
root 'admin/dashboard#index'
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
