class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]


  # Listar todos os usuários
  def index
    users = User.where.not(id: @current_user.id).order(created_at: :desc).page(params[:page]).per(5) # 5 usuários por página
    render json: {
      users: users,
      meta: {
        current_page: users.current_page,
        total_pages: users.total_pages,
        total_count: users.total_count
      }
    }, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = JsonWebToken.encode({ user_id: @user.id })
      render json: { token: token, message: "Usuário cadastrado com sucesso!" }, status: :created
    else
      render json: { errors: format_errors(@user.errors) }, status: :unprocessable_entity
    end
  end

    # Admin exclui usuários
    def destroy
      user = User.find(params[:id])
      if user.destroy
        render json: { message: "Usuário excluído com sucesso" }, status: :ok
      else
        render json: { errors: "Não foi possível excluir o usuário" }, status: :unprocessable_entity
      end
    end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
  end

  def format_errors(errors)
    errors.details.map do |field, details|
      details.map do |error_detail|
        {
          field: field,
          message: errors.full_message(field, error_detail[:error])
        }
      end
    end.flatten
  end
end
