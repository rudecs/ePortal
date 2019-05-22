location = Location.last
image = location.images.first

cs = CloudSpace.create!(location_id: location.id)
cs.process

m = Machine.create!(cloud_space_id: cs.id, image_id: image.id, memory: 1024, vcpus: 1, boot_disk_size: 10)

# p = Port.create!(cloud_space_id: cs.id, machine_id: m.id, cloud_protocol: 'tcp', cloud_local_port: 22, cloud_public_port: 22)
# d = Disk.create!(type: 'standard', machine_id: m.id, size: 10 )
# ss = Snapshot.create!(machine_id: m.id)



# ss1 = Snapshot.create!(machine_id: m.id)
# ss2 = Snapshot.create!(machine_id: m.id)
# ss3 = Snapshot.create!(machine_id: m.id)
# ss4 = Snapshot.create!(machine_id: m.id)
# ss5 = Snapshot.create!(machine_id: m.id)
