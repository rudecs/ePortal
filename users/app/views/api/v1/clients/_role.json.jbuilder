if role.present?
  json.(role, :id, :client_id, :name, :read_only, :permissions, :created_at)
end
