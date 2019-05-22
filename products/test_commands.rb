# test case: create VDC product instance
p_vdc = Product.first
pi_vdc = ProductInstance.create!(state: 'processing', product: p_vdc, handler_price: p_vdc.handler_price, client_id: 1)
pij_vdc = ProductInstanceJob.create!({
  state: 'new',
  product_instance_id: pi_vdc.id,
  handler_fn_name: 'create',
  handler_fn_params: {
    location_id: 1,
  },
})
pij_vdc.execute
pij_vdc.reload


p_vm = Product.last
pi_vm = ProductInstance.create!(state: 'processing', product: p_vm, handler_price: p_vm.handler_price, client_id: 1)
pij_vm = ProductInstanceJob.create!({
  state: 'new',
  product_instance_id: pi_vm.id,
  handler_fn_name: 'create',
  handler_fn_params: {
    # cloud_space_id: 123,
    location_id: 1,
    image_id: 100,
    vcpus: 1,
    memory: 1024,
    boot_disk_size: 10,
    additional_disks: [{ size: 10, name: 'dev_additional_5', type: 'standard' }],
  },
})
pij_vm.execute
pij_vm.reload


# add disk
pij_vm = ProductInstanceJob.create!({
  state: 'new',
  product_instance_id: 1, # set proper id
  handler_fn_name: 'add_disk',
  handler_fn_params: {
    # location_id: 1,
    machine_id: 176,
    size: 10,
    name: 'add_disk_1',
    type: 'standard',
  },
})
pij_vm.execute
pij_vm.reload


# delete disk
pij_vm = ProductInstanceJob.create!({
  state: 'new',
  product_instance_id: 1, # set proper id
  handler_fn_name: 'delete_disk',
  handler_fn_params: {
    id: 183
  },
})
pij_vm.execute
pij_vm.reload
