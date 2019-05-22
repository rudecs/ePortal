class AddLocationIdToHandlerVms < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :handler_vms, :location_id
      add_column :handler_vms, :location_id, :integer
    end

    Handler::VM.find_each do |vm_handler|
      vdc = vm_handler.product_instance_vdc
      if vdc.present?
        vm_handler.location_id = vdc.handler.location_id
        vm_handler.save!
      end
    end
  end
end
