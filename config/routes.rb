Rails.application.routes.draw do
  root to: redirect('/resources')

  # Resources
  resources :resources
  resources :bookings, except: :edit

  # Custom routes
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  # Error pages
  match '/404', to: 'application#not_found', via: :all
  match '/500', to: 'application#internal_server_error', via: :all
  match '/422', to: 'application#changes_rejected', via: :all
end
