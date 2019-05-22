class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.integer :resource_id
      t.string  :resource_type

      t.string :name
      t.hstore :params

      t.datetime :started_at
      t.datetime :finished_at
    end
  end
end
