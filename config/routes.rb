# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'users#index'

  resources :apps
  resources :lists
  get '/lists/:id/add', to: 'lists#add', as: 'list_add'
  post '/lists/:id/add', to: 'lists#find_app'
  resources :entries
  resources :users, param: :username
  get '/users/:username/bye', to: 'users#bye', as: 'user_bye'

  devise_for :users, path: 'auth', controllers: { omniauth_callbacks: 'omniauth_callbacks' }
end
