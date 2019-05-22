# frozen_string_literal: true

class DiskEvent < Event
  store_accessor :resource_parameters, :size, :disk_type, :cloud_type, :iops_sec, :bytes_sec

  validates :resource_parameters, presence: true
  validates :size, :iops_sec, :bytes_sec, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :disk_type, :cloud_type, presence: true

  class << self
    def chargable_size(events_resource_parameters)
      events_resource_parameters.max_by { |rp| rp['size'] }['size']
    end

    def chargable_iops_sec(events_resource_parameters)
      events_resource_parameters.max_by { |rp| rp['iops_sec'] }['iops_sec']
    end

    def chargable_bytes_sec(events_resource_parameters)
      events_resource_parameters.max_by { |rp| rp['bytes_sec'] }['bytes_sec']
    end

    def chargable_disk_type(events_resource_parameters)
      events_resource_parameters.last['disk_type'] # REVIEW: exclude from chargable?
    end

    def chargable_cloud_type(events_resource_parameters)
      events_resource_parameters.last['cloud_type'] # REVIEW: exclude from chargable?
    end
  end

  def size=(val)
    val.present? ? super(val.to_i) : super.to_i
  end

  def iops_sec=(val)
    val.present? ? super(val.to_i) : super.to_i
  end

  def bytes_sec=(val)
    val.present? ? super(val.to_i) : super.to_i
  end
end
