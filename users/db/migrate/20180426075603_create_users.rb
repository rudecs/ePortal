class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :state, null: false
      t.string :password_digest

      t.boolean :is_enabled_2fa, null: false

      t.string   :email
      t.datetime :email_confirmed_at
      t.string   :email_confirmation_code
      t.datetime :email_confirmation_code_expired_at

      t.string   :phone
      t.datetime :phone_confirmed_at
      t.string   :phone_confirmation_code
      t.datetime :phone_confirmation_code_expired_at

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
