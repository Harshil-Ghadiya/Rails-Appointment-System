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
    post 'login_as_admin/:id', to: 'dashboard#login_as_admin', as: 'login_as_admin'
  end

  get 'patient_info/:id', to: 'patient_portal#show_info', as: :patient_info

  namespace :admin do
    # Dashboard & Status Controls
    get 'dashboard', to: 'dashboard#index'
    get 'generate_qr', to: 'dashboard#generate_qr'
    
    patch 'toggle_booking', to: 'dashboard#toggle_booking'
    patch 'update_doctor_status', to: 'dashboard#update_doctor_status'

    
    # Ahiya line alag karvi pade:
patch 'dashboard/:id/update_status/:status', to: 'dashboard#update_status', as: :update_appt_status    
    resources :booking_controls, only: [:index, :update]
    resources :appointments, only: [:index]
    
    # Reserved Tokens
    resources :reserved_tokens, only: [:index, :create, :destroy] 
    
    # Field Settings
    resources :field_settings, only: [:index] do
      collection { patch :update_all }
    end
    
    # Notices
    resources :notices, only: [:index, :create, :destroy]
    
    # Profile
    resource :profile, only: [:edit, :update]
  end

  # Patient Side
  resources :appointments, only: [:new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
  
root to: redirect('/admin/dashboard')
end
