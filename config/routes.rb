Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  post "/cart/add_product", to: "carts#add_product" 
  post "/cart/add_item", to: "carts#add_item"  
  get "/cart", to: "carts#show" 
  delete "/cart/:product_id", to: "carts#remove_product" 

  resources :products

  get "up" => "rails/health#show", as: :rails_health_check
  get '/favicon.ico', to: proc { [200, {}, ['']] }

  root "rails/health#show"
end