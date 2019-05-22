class AddExpirationToInvitations < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :expired_at, :datetime
  end
end
