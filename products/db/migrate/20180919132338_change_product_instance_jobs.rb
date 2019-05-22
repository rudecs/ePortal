class ChangeProductInstanceJobs < ActiveRecord::Migration[5.1]
  def change
    remove_column :product_instance_jobs, :handler_fn_name
    add_column :product_instance_jobs, :action_name, :string

    remove_column :product_instance_jobs, :handler_fn_params
    add_column :product_instance_jobs, :action_params, :json

    add_column :product_instance_jobs, :error_messages, :json
  end
end
