class AddLastThresholdToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :last_threshold_at, :datetime
  end
end
