Rails.application.routes.draw do
  get '/spotify/search', to: 'spotify#results'
  get '/spotify/unknown', to: 'spotify#unknown'
  get '/spotify/recommendations_all', to: 'spotify#recommendations_all'
  
  # get 'home/index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, :only => [:show, :index]
  
  root to: 'home#index'

  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
