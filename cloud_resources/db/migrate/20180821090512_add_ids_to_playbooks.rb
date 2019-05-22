class AddIdsToPlaybooks < ActiveRecord::Migration[5.1]
  def change
    add_column :playbooks, :user_id, :integer
    add_column :playbooks, :client_id, :integer
    add_column :playbooks, :partner_id, :integer
    add_column :playbooks, :product_id, :integer
    add_column :playbooks, :product_instance_id, :integer
    add_column :playbooks, :product_instance_job_id, :integer
  end
end
