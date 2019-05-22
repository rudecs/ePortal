# frozen_string_literal: true

json.array! @resources do |keys, query_grouped_resources|
  query_grouped_resources.group_by(&:kind).each do |kind, resources|
    json.set! kind.tableize do
      json.ignore_nil!
      json.call(resources.first, :resources_count, :vcpus, :memory, :size, :disk_type, :cloud_type, :iops_sec, :bytes_sec, :image_name)
    end
  end
  json.merge! keys.compact
end
