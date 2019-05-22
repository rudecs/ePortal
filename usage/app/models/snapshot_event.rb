# frozen_string_literal: true

class SnapshotEvent < Event
  validates :resource_parameters, absence: true
end
