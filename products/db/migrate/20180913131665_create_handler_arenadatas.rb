class CreateHandlerArenadatas < ActiveRecord::Migration[5.1]
  def change
    create_table :handler_arenadatas do |t|
      t.integer :product_instance_id, null: false

      t.timestamps
    end
  end
end
