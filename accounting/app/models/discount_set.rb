class DiscountSet < ApplicationRecord
  include Monetizable
  monetize :amount

  belongs_to :discount
  belongs_to :discount_package

  attribute :amount_type, :string, default: 'percent'

  accepts_nested_attributes_for :discount, update_only: true, reject_if: :persisted?

  # we can add disabled_at column to disable discount, but information about it will remain
  validates :discount, :discount_package, :amount, presence: true
  validates :amount_type, presence: true, inclusion: { in: %w[percent quantity] }
  validates :discount_id, uniqueness: { scope: :discount_package_id }, if: proc { |ds| ds.discount_id && ds.discount_package_id } # REVIEW: unique per currency if fixed

  def fixed?
    amount_type == 'fixed'
  end
end
