class Playbooks::Sync::Machine < Playbooks::Sync::Base

  def sync_active_nil
    @resource = ::Machine.create!({
      id: @schema[:id],
      partner_id: @schema[:partner_id],
      client_id: @schema[:client_id],
      product_id: @schema[:product_id],
      product_instance_id: @schema[:product_instance_id],
      cloud_space_id: @schema[:cloud_space_id],
      image_id: @schema[:image_id],
      vcpus: @schema[:vcpus],
      memory: @schema[:memory],
      boot_disk_size: @schema[:boot_disk_size],
      name: @schema[:name],
      ssh_keys: @schema[:ssh_keys],
    })

    return self.sync
  end

  def sync_active_active
    # TODO: handle status change
    if @schema[:vcpus] == @resource.vcpus && @schema[:memory] == @resource.memory
      return true
    else
      @resource.resize(memory: @schema[:memory], vcpus: @schema[:vcpus])
      return self.sync
    end
  end

end
