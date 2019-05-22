class SnapshotSearch < Searchlight::Search

  def base_query
    Snapshot.distinct.order('snapshots.id desc')
  end

  def search_client_id
    query.where(client_id: client_id)
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_machine_id
    query.where(machine_id: machine_id)
  end

  def search_machine_ids
    query.where(machine_id: machine_ids)
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
