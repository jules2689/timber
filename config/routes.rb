Rails.application.routes.draw do
  resources :logs, only: [:index, :new, :create]
  root "logs#index"
end
