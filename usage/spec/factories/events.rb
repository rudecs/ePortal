# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    started_at 1.minute.ago
    finished_at Time.zone.now
  end

  factory :machine_event, parent: :event, class: 'MachineEvent' do
    # type will be defined?
    # assoc: machine_resource
    association :resource, factory: :machine_resource
    resource_parameters do
      { memory: 1, vcpus: 1 }
    end
  end

  factory :cloud_space_event, parent: :event, class: 'CloudSpaceEvent' do
    # type will be defined?
    # assoc: cloud_space_resource
    association :resource, factory: :cloud_space_resource
    resource_parameters do
      {}
    end
  end

  factory :disk_event, parent: :event, class: 'DiskEvent' do
    association :resource, factory: :cloud_space_resource
    resource_parameters do
      {
        size: 10,
        disk_type: 'standard',
        cloud_type: 'D',
        iops_sec: 3000,
        bytes_sec: 300
      }
    end
  end

  trait :create_event do
    name 0
    # TODO: add image name for machine event
  end

  trait :resize_event do
    name 1
  end

  trait :delete_event do
    name 2
  end
end
