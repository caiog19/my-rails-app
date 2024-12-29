class User < ApplicationRecord
  has_secure_password

  validates :full_name, presence: true, length: { maximum: 100 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: VALID_EMAIL_REGEX }

  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  validate :strong_password, if: :password_present?

  before_save :downcase_email
  before_save :capitalize_full_name

  def admin?
    self.admin
  end

  def generate_reset_token!
    update(
      reset_password_token: SecureRandom.hex(10),
      reset_password_sent_at: Time.now
    )
  end
  
  def lock!
    update(locked_at: Time.current)
  end

  def locked?
    locked_at.present? && locked_at > 30.minutes.ago 
  end

  def unlock!
    update(locked_at: nil, failed_attempts: 0)
  end

  private

  def password_present?
    password.present?
  end

  def strong_password
    regex = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}\z/
    unless password.match(regex)
      errors.add(:password, 'deve conter ao menos: 1 letra maiúscula, 1 letra minúscula, 1 número, 1 caractere especial e ter pelo menos 6 caracteres')
    end
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def capitalize_full_name
    self.full_name = full_name.split.map(&:capitalize).join(' ') if full_name.present?
  end
end
