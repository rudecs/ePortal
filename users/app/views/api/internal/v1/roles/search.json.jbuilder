json.roles @roles do |role|
  json.partial! 'roles/role.json', role: role
end

json.total_count @roles.total_entries
