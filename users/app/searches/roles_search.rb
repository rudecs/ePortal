class RolesSearch < Searchlight::Search

  def base_query
    Role
  end

  def options
    super.tap do |opts|
      # set default sort order
      unless opts[:sort_direction].present? # && opts[:sort_field].blank?
        opts[:sort_direction] = 'desc'
        # opts[:sort_direction] =
        #   case opts[:sort_field]
        #   when 'id' then 'desc'
        #   when 'created_at' then 'desc'
        #   else 'desc'
        #   end
      end
    end
  end

  def search_ids
    query.where(id: ids)
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_user_ids
    query.joins(profiles: :user).where(users: {id: user_ids})
  end

  def search_name
    query.where('roles.name ILIKE ?', str(name))
  end

  def search_deleted
    query.where.not(deleted_at: nil)
  end

  def search_sort_field
    query.order(sort_field + ' ' + options[:sort_direction])
  end

  private

  def str(param)
    ['%', param.to_s.strip.tr(' ', '%'), '%'].join
  end
end
