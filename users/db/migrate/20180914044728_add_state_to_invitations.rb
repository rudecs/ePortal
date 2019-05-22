class AddStateToInvitations < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :state, :integer, null: false, default: 0
  end
end
