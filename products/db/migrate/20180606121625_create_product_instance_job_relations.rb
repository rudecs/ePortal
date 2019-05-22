class CreateProductInstanceJobRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :product_instance_job_relations do |t|
      t.integer :job_id
      t.integer :before_job_id

      t.timestamps
    end
  end
end
