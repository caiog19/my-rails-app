Rails.application.routes.draw do

  begin
    require 'rswag/ui'
    if Rails.env.development? || Rails.env.test? || ENV['INCLUDE_SWAGGER'] == 'true'
      mount Rswag::Ui::Engine => '/api-docs'
      mount Rswag::Api::Engine => '/api-docs'
    end
  rescue LoadError
    # Do nothing if the gem isn't available
  end
  
  # Rotas para Posts
  resources :posts, only: [:index, :create, :update, :destroy] do
    resources :comments, only: [:index, :create]
    resources :tags, only: [:index]
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

  # Rotas para Tags
  resources :tags, only: [:index, :create, :destroy]

  get 'translations/:locale', to: 'translations#show'

  resources :file_uploads, only: [:create]
  
end
