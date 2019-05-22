# frozen_string_literal: true

class MachineEvent < Event
  store_accessor :resource_parameters, :memory, :vcpus

  validates :resource_parameters, presence: true
  validates :memory, :vcpus, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  class << self
    # TODO: refactor
    def chargable_memory(events_resource_parameters)
      events_resource_parameters.max_by { |rp| rp['memory'] }['memory']
    end

    def chargable_vcpus(events_resource_parameters)
      events_resource_parameters.max_by { |rp| rp['vcpus'] }['vcpus']
    end
  end

  # === resource_parameters setters ===
  # TODO: refactor
  def memory=(val)
    val.present? ? super(val.to_i) : super.to_i
  end

  def vcpus=(val)
    val.present? ? super(val.to_i) : super.to_i
  end
end
