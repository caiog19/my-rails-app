Rails.application.routes.draw do
  # Rotas para Posts
  resources :posts, only: [:index, :create, :update, :destroy] do
    resources :comments, only: [:index, :create]
  end

  # Raiz da aplicação
  root "posts#index"

  # Rotas para Usuários
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  # Rotas para Sessões
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Rotas para reset de senha
  resources :password_resets, only: [:create, :edit, :update], defaults: { format: :json }

  # Rota para favicon
  get '/favicon.ico', to: ->(_) { [204, {}, []] }

  # Rota para "meus posts"
  get '/meus-posts', to: 'posts#meus_posts'

  # Rotas para usuários
  resources :users, only: [:index, :destroy]

  # Rota de autenticação
  get '/auth/me', to: 'auth#me'

  #Att Perfil
  get '/auth/me', to: 'auth#me'
  put '/auth/update-profile', to: 'auth#update_profile'
end
