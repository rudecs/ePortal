class MachineSearch < Searchlight::Search

  def base_query
    Machine.distinct.order('machines.id desc')
  end

  def search_client_id
    query.where(client_id: client_id)
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_cloud_space_id
    query.where(cloud_space_id: cloud_space_id)
  end

  def search_cloud_space_ids
    query.where(cloud_space_id: cloud_space_ids)
  end

  def search_partner_id
    query.where(partner_id: partner_id)
  end

  def search_partner_ids
    query.where(partner_id: partner_ids)
  end

  def search_product_id
    query.where(product_id: product_id)
  end

  def search_product_ids
    query.where(product_id: product_ids)
  end

  def search_product_instance_id
    query.where(product_instance_id: product_instance_id)
  end

  def search_product_instance_ids
    query.where(product_instance_id: product_instance_ids)
  end

  def search_state
    query.where(state: state)
  end

  def search_states
    query.where(state: states)
  end

end
