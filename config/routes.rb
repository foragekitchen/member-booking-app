Rails.application.routes.draw do
  root to: redirect('/resources')

  # Resources
  resources :resources, only: :index
  resources :bookings, except: :edit

  # Custom routes
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  # Error pages
  %w( 404 422 500 ).each do |code|
    get code, to: 'application#error', code: code
  end
end
