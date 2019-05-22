# frozen_string_literal: true

namespace :migrate do
  desc 'Add ip for incoming CloudSpaceEvent'
  task set_cloud_space_event_params: :environment do
    start_time = Time.now
    puts "=== Start update at (#{start_time}) ==="

    CloudSpaceEvent.where(resource_parameters: {}).update_all(resource_parameters: { bandwidth: 10 })
    Payload.where(chargable: {}).update_all(chargable: { bandwidth: 10 })

    end_time = Time.now
    duration = end_time - start_time
    puts "=== Task finished at (#{end_time}). It took #{duration} seconds. ==="
  end
end
