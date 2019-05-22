json.cloud_spaces @cloud_spaces do |cloud_space|
  json.partial! 'cloud_spaces/cloud_space.json', cloud_space: cloud_space
end
