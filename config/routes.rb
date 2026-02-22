Rails.application.routes.draw do
  root "maps#new"

  resources :maps, only: [ :new, :create, :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
