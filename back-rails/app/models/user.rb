class User < ApplicationRecord
  has_secure_password 

  validates :full_name, presence: true, length: { maximum: 100 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false }, 
                    format: { with: VALID_EMAIL_REGEX }

  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  # Callbacks
  before_save :downcase_email

  validates :admin, inclusion: { in: [true, false] }
  before_save :capitalize_full_name
  def generate_reset_token!
    update(
      reset_password_token: SecureRandom.hex(10),
      reset_password_sent_at: Time.now
    )
  end
  def admin?
    self.admin
  end
  private
  def downcase_email
    self.email = email.downcase if email.present?
  end
  def capitalize_full_name
    self.full_name = full_name.split.map(&:capitalize).join(' ') if full_name.present?
  end
end
