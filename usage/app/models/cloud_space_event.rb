# frozen_string_literal: true

class CloudSpaceEvent < Event
  validates :resource_parameters, absence: true
  # store_accessor :resource_parameters, :bandwidth

  # validates :resource_parameters, presence: true
  # validates :bandwidth, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # class << self
  #   def chargable_bandwidth(events_resource_parameters)
  #     events_resource_parameters.max_by { |rp| rp['bandwidth'] }['bandwidth']
  #   end
  # end

  # def bandwidth=(val)
  #   val.present? ? super(val.to_i) : super.to_i
  # end
end
