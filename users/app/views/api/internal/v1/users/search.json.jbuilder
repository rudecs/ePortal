json.users @users do |user|
  json.partial! 'users/user.json', user: user
end

json.total_count @users.total_entries
