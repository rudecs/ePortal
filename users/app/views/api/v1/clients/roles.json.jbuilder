json.roles @roles do |role|
  json.partial! 'clients/role.json', role: role
end
