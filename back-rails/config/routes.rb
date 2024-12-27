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

  # Rotas para Recuperação de Senha
  resources :password_resets, only: [:create, :edit, :update]

end
