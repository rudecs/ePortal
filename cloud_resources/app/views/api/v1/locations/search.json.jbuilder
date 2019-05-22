json.locations @locations do |location|
  json.(location, :id, :code, :gid, :state, :url, :created_at, :updated_at, :deleted_at)
end

json.total_count @locations.count
