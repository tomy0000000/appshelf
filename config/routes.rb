# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'lists#index'

  resources :apps
  resources :lists
  resources :entries
  resources :users, param: :username

  devise_for :users, path: 'auth'
end
