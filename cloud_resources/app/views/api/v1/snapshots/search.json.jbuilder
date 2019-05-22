json.snapshots @snapshots do |snapshot|
  json.partial! 'snapshots/snapshot.json', snapshot: snapshot
end
