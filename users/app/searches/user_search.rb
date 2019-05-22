class UserSearch < Searchlight::Search

  def base_query
    User.distinct
  end

  def options
    super.tap do |opts|
      opts[:sort_direction] = 'desc' unless opts[:sort_direction].present?
    end
  end

  def search_id
    query.where(id: id)
  end

  def search_ids
    query.where(id: ids)
  end

  def search_client_id
    query.joins(profiles: {role: :client}).where(clients: {id: client_id})
  end

  def search_client_ids
    query.joins(profiles: {role: :client}).where(clients: {id: client_ids})
  end

  def search_state
    query.where(state: state)
  end

  def search_states
    query.where(state: states)
  end

  def search_sort_field
    query.reorder(sort_field + ' ' + options[:sort_direction])
  end

  def search_identifier
    query.search_by_identifier(identifier).with_pg_search_rank
  end
end
