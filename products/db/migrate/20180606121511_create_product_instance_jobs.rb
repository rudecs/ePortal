class CreateProductInstanceJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :product_instance_jobs do |t|
      t.integer :product_instance_id
      t.integer :playbook_id

      t.string :handler_fn_name
      t.json :handler_fn_params

      t.string :state

      t.datetime :created_at
      t.datetime :finished_at
    end
  end
end
