class Playbooks::Sync::Snapshot < Playbooks::Sync::Base

  def sync_active_nil
    @resource = ::Snapshot.create!({
      id: @schema[:id],
      partner_id: @schema[:partner_id],
      client_id: @schema[:client_id],
      product_id: @schema[:product_id],
      product_instance_id: @schema[:product_instance_id],
      machine_id: @schema[:machine_id],
      name: @schema[:name],
    })

    return self.sync
  end

end
