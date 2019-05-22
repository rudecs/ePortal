class CreateInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :invitations do |t|
      t.integer  :sender_id, null: false
      t.integer  :client_id, null: false
      t.integer  :role_id,   null: false
      t.integer  :receiver_id
      t.string   :email
      t.string   :token
      # t.string   :state pending/accepted/rejected

      t.timestamps
    end

    add_index :invitations, :sender_id
    add_index :invitations, :receiver_id
    add_index :invitations, :client_id
    add_index :invitations, :role_id
    add_index :invitations, :token, unique: true
    add_index :invitations, [:client_id, :email], unique: true # OR [:sender_id, :email]
  end
end
