# frozen_string_literal: true

class Event < ApplicationRecord
  enum name: { create: 0, resize: 1, delete: 2 }, _suffix: true # change with cautions, lots of logic relies on this
  START_TIME_EVENTS = %w[resize delete].freeze

  belongs_to :resource

  validates :resource, :started_at, :finished_at, presence: true
  validates :type, presence: true, inclusion: { in: %w[CloudSpaceEvent MachineEvent DiskEvent PortEvent SnapshotEvent] }
  validates :name, presence: true, inclusion: { in: names.keys }
  # uniq start_time per resource_id?

  validate :started_at_greater_than_finished_at, if: proc { |e| e.started_at.present? && e.finished_at.present? }
  validate :one_create_and_delete_per_resource, if: proc { |e| e.resource.present? }
  validate :type_name, if: proc { |e| e.resource.present? && e.type.present? }

  # be careful, cause started/finished_at columns have limit=3, when passing datetime with default prescision=6
  # Through current codebase we use only Period_start, where Time.usec = 0.
  scope :started_before, ->(datetime) { where('started_at < ?', datetime) }
  scope :finished_before, ->(datetime) { where('finished_at < ?', datetime) }

  def readonly?
    !new_record?
  end

  private

  def started_at_greater_than_finished_at
    errors.add(:finished_at, 'is less than started_at') if finished_at < started_at
  end

  def one_create_and_delete_per_resource
    errors.add(:base, 'Only one event of this type can persist per resource') if (delete_name? && resource.events.delete_name.present?) || (create_name? && resource.events.create_name.present?)
  end

  def type_name
    errors.add(:type, 'invalid for event`s resource') if type != [resource.kind, 'Event'].join
  end

  # errors.add() if resource.soft_deleted? && (finished_at > resource.deleted_at || started_at > resource.deleted_at)
  # resource.deleted_at = when client pressed 'delete'

  # errors.add() if finished_at < resource.originally_created_at ||
  # Can only validate finished_at OR use resource.events.create_name.first.started_at
  # which seems overcomplicated.
end
