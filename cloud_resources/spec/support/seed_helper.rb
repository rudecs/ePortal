RSpec.configure do |config|

  # config.before(:each) do |example|
  config.before(:all) do |example|
    # I18n.locale = 'en'

    $location = Location.create!({
      code: 'mr4',
      url: 'https://mr4.digitalenergy.online',
      state: 'active',
    })


    # synchronizer = Playbooks::Sync::CloudSpace.new({
    #   id: ResourceIdSequence.nextval,
    #   location_id: $location.id,
    #   state: 'active',
    # })
    # synchronizer.sync
    # $cloud_space = synchronizer.cloud_space
    #
    # synchronizer = Playbooks::Sync::Machine.new({
    #   id: ResourceIdSequence.nextval,
    #   cloud_space_id: $cloud_space.id,
    #   state: 'active',
    #   vcpus: 1,
    #   memory: 1024,
    #   boot_disk_size: 10,
    # })
    # synchronizer.sync
    # $machine = synchronizer.machine

    # $image = CloudResource::Image.first
    #
    # Sidekiq::Testing.inline! do
    #   $cloud_space = CloudResource::API::CreateCloudSpace.new({
    #     cloud_space: {
    #       location_id: $location.id,
    #       name: 'seed-cloud-space',
    #       description: 'seed cloud space description',
    #     },
    #   }).run
    # end

  end

end
