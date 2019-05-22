class Playbooks::Sync::Port < Playbooks::Sync::Base

  def sync_active_nil
    resource = ::Port.create!({
      id: @schema[:id],
      partner_id: @schema[:partner_id],
      client_id: @schema[:client_id],
      product_id: @schema[:product_id],
      product_instance_id: @schema[:product_instance_id],
      cloud_space_id: @schema[:cloud_space_id],
      machine_id: @schema[:machine_id],
      cloud_public_port: @schema[:cloud_public_port],
      cloud_local_port: @schema[:cloud_local_port],
      cloud_protocol: @schema[:cloud_protocol],
    })

    return self.sync
  end

  def sync_active_active
    if @schema[:cloud_public_port] != @resource.cloud_public_port ||
       @schema[:cloud_local_port] != @resource.cloud_local_port ||
       @schema[:cloud_protocol] != @resource.cloud_protocol
      @resource.update({
        cloud_public_port: @schema[:cloud_public_port],
        cloud_local_port: @schema[:cloud_local_port],
        cloud_protocol: @schema[:cloud_protocol],
      })
      return self.sync
    end

    return true
  end

end
