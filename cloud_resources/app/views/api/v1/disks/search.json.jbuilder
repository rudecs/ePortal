json.disks @disks do |disk|
  json.partial! 'disks/disk.json', disk: disk
end
