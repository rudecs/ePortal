class Playbooks::Sync::Disk < Playbooks::Sync::Base

  def sync_active_nil
    @resource = ::Disk.create!({
      id: @schema[:id],
      partner_id: @schema[:partner_id],
      client_id: @schema[:client_id],
      product_id: @schema[:product_id],
      product_instance_id: @schema[:product_instance_id],
      machine_id: @schema[:machine_id],
      name: @schema[:name],
      size: @schema[:size],
      type: @schema[:disk_type],
      iops_sec: @schema[:iops_sec],
    })

    return self.sync
  end

  def sync_active_active
    if @schema[:size] > @resource.size
      @resource.resize(@schema[:size], @schema[:iops_sec])
    elsif @schema[:size] < @resource.size
      return false
    else
      if @schema[:iops_sec] != @resource.iops_sec
        @resource.limit_io(@schema[:iops_sec])
      else
        return true
      end
    end
  end

end
