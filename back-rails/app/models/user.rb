class User < ApplicationRecord
  has_secure_password 
  validates :email, presence: true, uniqueness: true
  has_many :posts
  has_many :comments

  def generate_reset_token!
    update(
      reset_password_token: SecureRandom.hex(10),
      reset_password_sent_at: Time.now
    )
  end
end
