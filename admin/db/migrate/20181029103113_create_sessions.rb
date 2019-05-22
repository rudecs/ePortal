class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.integer :user_id, null: false
      t.string :token, null: false

      t.string   :sms_token
      t.datetime :sms_token_expired_at
      t.datetime :sms_token_confirmed_at

      t.timestamps
      t.datetime :expired_at
    end

    add_index :sessions, :token, unique: true
    add_index :sessions, :user_id
  end
end
