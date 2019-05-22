class AddDeliveredFieldsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :created_at, :datetime
    add_column :events, :delivered_at, :datetime
  end
end
