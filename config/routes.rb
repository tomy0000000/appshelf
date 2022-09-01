Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'lists#index'

  resources :apps
  resources :lists

  get '/apps/peak/:id', to: 'apps#peak'
end
