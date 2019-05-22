class RemoveUserConstraintOnNotifications < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:notifications, :user_id, true)
    add_column :notifications_requests, :emails, :string, array: true, default: []
    add_column :notifications_requests, :phones, :string, array: true, default: []
  end
end
