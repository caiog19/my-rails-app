Rails.application.routes.draw do
  
  # Rotas para Posts
  resources :posts, only: [:index, :create]
  root "posts#index"

  # Rotas para Usuários
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  # Rotas para Sessões
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :password_resets, only: [:create, :edit, :update], defaults: { format: :json }

  get '/favicon.ico', to: ->(_) { [204, {}, []] }

  resources :posts, only: [:index, :create, :update, :destroy]

  get '/meus-posts', to: 'posts#meus_posts'

  resources :users, only: [:index, :destroy]


  get '/auth/me', to: 'auth#me'
  resources :posts, only: [:index, :create, :update, :destroy]
  resources :users, only: [:index, :destroy]
end
