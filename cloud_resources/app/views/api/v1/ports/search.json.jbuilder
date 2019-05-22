json.ports @ports do |port|
  json.partial! 'ports/port.json', port: port
end
