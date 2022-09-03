Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'lists#index'

  resources :apps
  get '/apps/peak/:id', to: 'apps#peak'
  resources :lists
  
  devise_for :users
end
