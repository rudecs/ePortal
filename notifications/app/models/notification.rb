class Notification < ApplicationRecord
  # include Clients::BalanceMethods
  include DeliveryMethods

  belongs_to :notifications_request
  belongs_to :template, optional: true # has_one?

  validates :notifications_request, :content, presence: true
  validates :delivery_method, inclusion: { in: delivery_methods.keys } # , presence: true
  validates :destination, presence: true, if: proc { |n| %w(email sms).include?(n.delivery_method) }

  scope :unread, -> { where(read_at: nil) }

  def mark_as_read
    touch :read_at
  end

  def delivered!
    touch :delivered_at
  end
end
