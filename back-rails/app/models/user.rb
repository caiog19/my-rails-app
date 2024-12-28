class User < ApplicationRecord
  has_secure_password 

  validates :email,
            presence: { message: "não pode estar em branco" },
            uniqueness: { message: "já está em uso" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "não é válido" }

  validates :full_name,
            presence: { message: "não pode estar em branco" },
            length: { maximum: 100, message: "deve ter no máximo 100 caracteres" }

  validates :password,
            presence: { message: "não pode estar em branco" },
            confirmation: { message: "não coincide com a confirmação" },
            length: { minimum: 8, message: "deve ter no mínimo 8 caracteres" }

  validates :password_confirmation,
            presence: { message: "é obrigatório" }

  before_save :capitalize_full_name
  def generate_reset_token!
    update(
      reset_password_token: SecureRandom.hex(10),
      reset_password_sent_at: Time.now
    )
  end

  private

  def capitalize_full_name
    self.full_name = full_name.split.map(&:capitalize).join(' ') if full_name.present?
  end
end
