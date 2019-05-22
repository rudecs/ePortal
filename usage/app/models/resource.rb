# frozen_string_literal: true

class Resource < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :payloads, dependent: :destroy

  validates :product_id, :client_id, :partner_id, :product_instance_id, presence: true
  validates :resource_id, presence: true, uniqueness: true
  validates :kind, presence: true, inclusion: { in: %w[CloudSpace Machine Disk Port Snapshot] }
  # REVIEW: validations for client id per product_instance_id
  # and product_instance_id per product_id.
  # It's not a concern of Usage microservice, but afterall data should be valid.

  # TODO: first event may not be create
  # validate :image_name, on: :create

  scope :active, -> { where(deleted_at: nil) }

  def soft_deleted?
    deleted_at.present?
  end

  # Returns last event before billing's period start
  def last_event_before(period_start)
    # We assume that there is no way of two resource's events with equal started_at
    events.started_before(period_start).where.not(name: :create)
          .or(events.create_name.finished_before(period_start))
          .order(name: :desc, started_at: :desc)
          .first
  end
end
