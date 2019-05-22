class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer  :resource_id, null: false
      t.integer  :name, null: false
      t.string   :type, null: false
      t.jsonb    :resource_parameters, null: false, default: {}
      t.datetime :started_at, null: false, limit: 3
      t.datetime :finished_at, null: false, limit: 3

      t.timestamps
    end
    add_index :events, :resource_id
    add_index(:events, [:name, :started_at], order: { name: :desc, started_at: :desc })
    # query example: res_id, name, started_at(except create event) || same + finished_at(for create event which is 1 per resource)
    # Separate [:name, :finished_at] || name, finished_at index? resource_id?
  end
end
