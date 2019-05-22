class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      # t.integer  :subject_id, null: false
      # t.string   :subject_type, null: false
      t.integer  :notifications_request_id, null: false
      t.integer  :user_id, null: false
      t.text     :content, null: false
      t.integer  :template_id
      t.integer  :delivery_method, null: false
      t.string   :destination
      t.datetime :delivered_at
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :notifications_request_id
  end
end
