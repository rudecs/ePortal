class ProductInstanceSearch < Searchlight::Search

  def base_query
    ProductInstance.select("DISTINCT ON (product_instances.id) *").order('product_instances.id desc')
  end

  def options
    super.tap do |opts|
      opts[:sort_field] = 'products.type' if opts[:sort_field] == 'product_type'
      opts[:sort_direction] = 'desc' unless opts[:sort_direction].present?
    end
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_product_ids
    query.where(product_id: product_ids)
  end

  def search_product_types
    query.joins(:product).where(products: {type: product_types.to_s.downcase.strip})
  end

  def search_states
    query.where(state: states)
  end

  def search_name
    query.where('product_instances.name ILIKE ?', str(name))
  end

  def search_sort_field
    sort_query = query.reorder(sort_field + ' ' + options[:sort_direction])
    return sort_query unless sort_field == 'products.type' || options[:product_types].blank?
    sort_query.includes(:product) # .references(:products)
  end

  private

  def str(param)
    ['%', param.to_s.strip.tr(' ', '%'), '%'].join
  end
end
