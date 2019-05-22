class Discount < ApplicationRecord
  has_many :discount_sets, dependent: :destroy
  has_many :discount_packages, through: :discount_sets

  validates :key_name, presence: true, uniqueness: true
end
