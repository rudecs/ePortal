class CreatePayloads < ActiveRecord::Migration[5.2]
  def change
    create_table :usages do |t|
      t.integer  :resource_id
      t.jsonb    :chargable, null: false, default: {}
      t.datetime :period_start, null: false, limit: 3
      t.datetime :period_end, null: false, limit: 3

      t.timestamps
    end
    add_index :usages, :resource_id
    add_index :usages, [:resource_id, :period_start, :period_end], name: 'uniq_payload_period_per_resource', unique: true
  end
end
