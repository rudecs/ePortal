class Playbooks::Sync::CloudSpace < Playbooks::Sync::Base

  # создать resource
  def sync_active_nil
    @resource = ::CloudSpace.create!({
      id: @schema[:id],
      partner_id: @schema[:partner_id],
      client_id: @schema[:client_id],
      product_id: @schema[:product_id],
      product_instance_id: @schema[:product_instance_id],
      location_id: @schema[:location_id],
      name: @schema[:name],
    })

    self.process_resource

    return self.sync
  end

end
