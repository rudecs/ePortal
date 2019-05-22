json.users @users do |user|
  json.partial! 'clients/user.json', user: user
end
