class ClientsSearch < Searchlight::Search

  def base_query
    Client
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

  def search_state
    query.where(state: state)
  end

  def search_states
    query.where(state: states)
  end

  def search_name
    query.where('clients.name ILIKE ?', str(name))
  end

  def search_business_entity_type
    query.where(business_entity_type: business_entity_type)
  end

  def search_currency
    query.where(currency: currency)
  end

  def search_writeoff_type
    query.where(writeoff_type: writeoff_type)
  end

  def search_writeoff_interval
    query.where(writeoff_interval: writeoff_interval)
  end

  def search_discount_package_id
    query.where(discount_package_id: discount_package_id)
  end

  def search_deleted
    query.where.not(deleted_at: nil)
  end

  def search_users_counter
    query.includes(roles: :profiles)
         .select(
           <<~SQL
             clients.*,
             (
               SELECT COUNT(profiles.id)
               FROM roles INNER JOIN profiles ON profiles.role_id = roles.id
               WHERE roles.client_id = clients.id
             ) AS users_count
           SQL
         )
  end

  def search_sort_field
    query.order(sort_field + ' ' + options[:sort_direction])
  end

  private

  def str(param)
    ['%', param.to_s.strip.tr(' ', '%'), '%'].join
  end
end
