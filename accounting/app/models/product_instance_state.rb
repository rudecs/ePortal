class ProductInstanceState < ApplicationRecord
  belongs_to :writeoff

  validates :writeoff_id, :product_id, :product_instance_id, :billing_data, :start_at, :end_at, presence: true
end
