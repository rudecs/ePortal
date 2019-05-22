class AddCurrentEventIdToPorts < ActiveRecord::Migration[5.1]
  def change
    add_column :ports, :current_event_id, :integer
  end
end
