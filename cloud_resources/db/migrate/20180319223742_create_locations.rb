class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.string  :code
      t.integer :gid
      t.string  :url
      t.string  :state

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
