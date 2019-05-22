class ProductInstance < ApplicationRecord
  has_many :billing_code_versions, dependent: :destroy
  has_one :current_billing_code_version, class_name: 'BillingCodeVersion'
end
