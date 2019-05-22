require 'rails_helper'

RSpec.describe Playbooks::Sync::Machine do

  it "create, delete and try delete deleted" do
    synchronizer = Playbooks::Sync::CloudSpace.new({
      id: ResourceIdSequence.nextval,
      location_id: $location.id,
      state: 'active',
    })
    synchronizer.sync
    cloud_space = synchronizer.cloud_space

    schema_active = {
      id: ResourceIdSequence.nextval,
      cloud_space_id: cloud_space.id,
      image_id: $location.images.first.id,
      state: 'active',
      vcpus: 1,
      memory: 1024,
      boot_disk_size: 10,
    }

    schema_resized = {
      id: schema_active[:id],
      cloud_space_id: schema_active[:cloud_space_id],
      state: 'active',
      vcpus: 2,
      memory: 2048,
      boot_disk_size: 10,
    }

    schema_deleted = {
      id: schema_active[:id],
      cloud_space_id: schema_active[:cloud_space_id],
      state: 'deleted',
    }


    # create
    machine = nil
    synchronizer = Playbooks::Sync::Machine.new(schema_active, machine)
    resp = synchronizer.sync
    expect(resp).to be true
    expect(synchronizer.machine.id).to eq(schema_active[:id])
    expect(synchronizer.machine.state).to eq('active')
    expect(synchronizer.machine.vcpus).to eq(schema_active[:vcpus])
    expect(synchronizer.machine.memory).to eq(schema_active[:memory])
    expect(synchronizer.machine.boot_disk_size).to eq(schema_active[:boot_disk_size])

    # try create created
    machine = synchronizer.machine
    synchronizer = Playbooks::Sync::Machine.new(schema_active, machine)
    resp = synchronizer.sync
    expect(resp).to be true
    expect(synchronizer.machine.id).to eq(schema_active[:id])
    expect(synchronizer.machine.state).to eq('active')
    expect(synchronizer.machine.vcpus).to eq(schema_active[:vcpus])
    expect(synchronizer.machine.memory).to eq(schema_active[:memory])
    expect(synchronizer.machine.boot_disk_size).to eq(schema_active[:boot_disk_size])

    # try resize active
    machine = synchronizer.machine
    synchronizer = Playbooks::Sync::Machine.new(schema_resized, machine)
    resp = synchronizer.sync
    expect(resp).to be true
    expect(synchronizer.machine.id).to eq(schema_active[:id])
    expect(synchronizer.machine.state).to eq('active')
    expect(synchronizer.machine.vcpus).to eq(schema_resized[:vcpus])
    expect(synchronizer.machine.memory).to eq(schema_resized[:memory])
    expect(synchronizer.machine.boot_disk_size).to eq(schema_resized[:boot_disk_size])

    # delete
    machine = synchronizer.machine
    synchronizer = Playbooks::Sync::Machine.new(schema_deleted, machine)
    resp = synchronizer.sync
    expect(resp).to be true
    expect(synchronizer.machine.id).to eq(schema_active[:id])
    expect(synchronizer.machine.state).to eq('deleted')

    # try delete deleted
    machine = synchronizer.machine
    synchronizer = Playbooks::Sync::Machine.new(schema_deleted, machine)
    resp = synchronizer.sync
    expect(resp).to be true
    expect(synchronizer.machine.id).to eq(schema_active[:id])
    expect(synchronizer.machine.state).to eq('deleted')
  end

end
