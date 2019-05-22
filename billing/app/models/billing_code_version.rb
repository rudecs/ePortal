class BillingCodeVersion < ApplicationRecord
  LANGUAGES = %w(js go ruby).freeze

  belongs_to :product_instance

  validates_presence_of :code, :lang
  validates :lang, inclusion:  { in: LANGUAGES }
end
