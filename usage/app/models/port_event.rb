# frozen_string_literal: true

class PortEvent < Event
  validates :resource_parameters, absence: true
end
