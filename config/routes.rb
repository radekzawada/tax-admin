Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  namespace :admin do
    get :mailbox, to: "mailbox#index"
    post "mailbox/template_file", to: "mailbox#create_template_file"

    resources :message_templates, only: %i[show] do
      resources :messages_packages, only: %i[create] do
        get :draft_messages, on: :member
      end
    end
  end

  # Defines the root path route ("/")
  root to: "admin/dashboard#index"
end
