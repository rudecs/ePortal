class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description

      t.string :type
      t.string :state

      t.string :handler_api
      t.string :handler_price
      t.json :params

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
