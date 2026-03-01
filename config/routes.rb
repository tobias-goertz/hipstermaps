Rails.application.routes.draw do
  root "maps#new"

  resources :maps, only: [ :new, :create, :show ] do
    member do
      get :image
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
