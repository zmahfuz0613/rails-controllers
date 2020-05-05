Rails.application.routes.draw do
  resources :posts
  resources :users
  get '/our-custom-route', to: 'users#easter_egg'
  get '/random-user', to: 'users#friend_request'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
