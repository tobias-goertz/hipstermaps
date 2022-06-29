Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "maps#new"

  resources :maps, only: [:create, :show, :new] do
    get :status
  end

  get ".well-known/health-check", to: "health#health_check"
end
