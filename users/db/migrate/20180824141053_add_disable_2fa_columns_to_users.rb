class AddDisable2faColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :disable_2fa_confirmation_code, :string
    add_column :users, :disable_2fa_confirmation_code_expired_at, :datetime
  end
end
