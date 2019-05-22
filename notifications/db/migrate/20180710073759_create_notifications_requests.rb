class CreateNotificationsRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications_requests do |t|
      t.datetime :processed_at
      t.string   :key_name
      t.text     :content
      t.integer  :delivery_method
      t.integer  :client_ids, array: true, default: []
      t.string   :category
      t.integer  :user_ids, array: true, default: []
      t.jsonb    :provided_data, null: false, default: {}

      t.timestamps
    end
  end
end
