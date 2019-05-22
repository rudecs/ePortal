handler_price = File.open(Rails.root.join('handler_price.js')).read

Product.find_each {|p| p.handler_price = handler_price; p.save!}
ProductInstance.find_each {|pi| pi.handler_price = handler_price; pi.save!}

# ==============================================================================
# Create VDC
context1 = ProductInstance::VDC::Create.call({
  client_id: 1,
  product_id: Product.find_by(type: 'vdc').id,
  location_id: 1,
  name: 'My VDC',
  description: 'This is VDC',
})

context2 = context1.job.process

# ==============================================================================
# Delete VDC
context3 = ProductInstance::VDC::Delete.call({
  product_instance_id: context1.product_instance.id
})

context4 = ProductInstanceJob.last.process


# ==============================================================================
# Create VM on exists VDC
context5 = ProductInstance::VM::Create.call({
  client_id: 1,
  image_id: 100,
  product_id: Product.find_by(type: 'vm').id,
  product_instance_vdc_id: context1.product_instance.id,
  name: 'VM on exists VDC',
  description: 'VM description',
  vcpus: 1,
  memory: 1024,
  boot_disk_size: 10,
  additional_disks: [
    {
      name: 'addictional disk',
      type: 'custom',
      size: 50,
      iops_sec: 1000,
    }
  ]
})

context6 = context5.job.process



# ==============================================================================
# Delete VM

context9 = ProductInstance::VM::Delete.call({
  product_instance_id: context5.product_instance.id
})

context10 = ProductInstanceJob.last.process



# ==============================================================================
# Create VM without VDC
context7 = ProductInstance::VM::Create.call({
  client_id: 1,
  image_id: 100,
  product_id: Product.find_by(type: 'vm').id,
  product_instance_vdc_product_id: context1.product.id,
  product_instance_vdc_location_id: 1,
  product_instance_vdc_name: 'Auto Created VDC',
  product_instance_vdc_description: 'description for VDC',
  name: 'VM with autocreated VDC',
  description: 'VM description',
  vcpus: 1,
  memory: 1024,
  boot_disk_size: 10,
  additional_disks: [
    {
      name: 'addictional disk',
      type: 'custom',
      size: 50,
      iops_sec: 1000,
    }
  ]
})

context8 = context7.job.process


# ==============================================================================
# Delete failed product instances
ProductInstance.joins(:product).where(state: 'failed', products: {type: 'vm'}).find_each do |pi|
  ProductInstance::VM::Delete.call(product_instance: pi)
end
ProductInstance.joins(:product).where(state: 'failed', products: {type: 'vdc'}).find_each do |pi|
  ProductInstance::VDC::Delete.call(product_instance: pi)
end

# ==============================================================================
