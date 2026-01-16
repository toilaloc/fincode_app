# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      # Health check endpoint for ECS/ALB
      get '/health', to: 'health#show'

      namespace :dropdowns do
        resources :categories, only: %i[index]
      end

      post '/signup', to: 'users#create'
      post '/magic_links/request_magic_link', to: 'magic_links#request_magic_link'
      get '/magic_links/verify', to: 'magic_links#verify', as: :magic_link
      delete '/magic_links/logout', to: 'magic_links#logout'

      resources :users, only: %i[create show update destroy]
      resources :categories, only: %i[index create show update destroy]
      resources :products, only: %i[index create show update destroy]
      resources :payments, only: [:index, :show], param: :order_id do
        collection do
          post :register
        end
        member do
          post :execute
          post :confirm
          post :capture
          post :cancel
        end
      end
    end
  end
end
