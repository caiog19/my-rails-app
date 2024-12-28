class AddAdminUser < ActiveRecord::Migration[6.1]
  def up
    User.create!(
      email: 'admin@example.com',
      password: 'Admin123',
      password_confirmation: 'Admin123',
      full_name: 'Administrator',
      admin: true
    )
  end

  def down
    User.find_by(email: 'admin@example.com')&.destroy
  end
end
