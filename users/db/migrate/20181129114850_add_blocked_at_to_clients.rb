class AddBlockedAtToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :blocked_at, :datetime
  end
end
