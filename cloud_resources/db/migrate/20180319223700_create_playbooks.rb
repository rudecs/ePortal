class CreatePlaybooks < ActiveRecord::Migration[5.1]
  def change
    create_table :playbooks do |t|
      t.string :state
      t.json :error_messages
      t.json :schema

      t.timestamps
    end
  end
end
