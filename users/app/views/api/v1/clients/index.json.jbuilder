json.clients @clients do |client|
  json.partial! 'clients/client.json', client: client
end

json.total_count @clients.total_entries
