class AddResetPasswordToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_reset_code, :string
    add_column :users, :password_reset_code_expired_at, :datetime
  end
end
