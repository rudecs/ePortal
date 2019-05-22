class DropProductInstanceJobRelation < ActiveRecord::Migration[5.1]
  def change
    drop_table :product_instance_job_relations, if_exists: true
  end
end
