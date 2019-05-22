if user.present?
  json.(user, :id, :first_name, :last_name, :email, :state, :created_at, :role_id, :role_name)
end
