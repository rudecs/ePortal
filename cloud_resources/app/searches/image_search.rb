class ImageSearch < Searchlight::Search

  def base_query
    Image.distinct.where(state: 'active', deleted_at: nil).order('images.id desc')
  end

  def search_location_id
    query.where(location_id: location_id)
  end

end
