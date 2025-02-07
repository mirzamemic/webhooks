Rails.application.routes.draw do
  namespace :webhooks do
    resource :stripe, only: :create, controller: "stripe"
  end

  resources :subscriptions, only: %i[index]

  # Default dev:secret.
  # Run `rails credentials:edit` to set basic authentication credentials.
  # More info: https://github.com/rails/mission_control-jobs#authentication
  mount MissionControl::Jobs::Engine, at: "/jobs"


  get "up" => "rails/health#show", as: :rails_health_check
  root to: "subscriptions#index"
end
