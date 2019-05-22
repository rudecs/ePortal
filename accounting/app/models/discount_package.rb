class DiscountPackage < ApplicationRecord
  has_many :clients, dependent: :nullify
  has_many :discount_sets, dependent: :destroy
  has_many :discounts, through: :discount_sets

  accepts_nested_attributes_for :discount_sets, allow_destroy: true

  # we can add disabled_at column to disable package, but information about it will remain

  validates :name, presence: true, uniqueness: true
end
