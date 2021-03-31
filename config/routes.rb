Rails.application.routes.draw do
  root to: redirect('/resources')

  # Resources
  resources :resources, only: :index
  resources :bookings, except: :edit

  get 'upcoming_bookings', to: 'upcoming#index'

  # Custom routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  # Error pages
  %w[404 422 500].each do |code|
    get code, to: 'application#error', code: code
  end
end
