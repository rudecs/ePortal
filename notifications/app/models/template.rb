class Template < ApplicationRecord
  include DeliveryMethods

  belongs_to :templates_set
  has_many :notifications #, dependent: :destroy

  validates :content, presence: true
  validates :locale, inclusion: { in: %w(en ru) } # presence?
  validates :delivery_method, inclusion: { in: delivery_methods.keys }, uniqueness: { scope: %i(templates_set locale) }
  validates :subject, presence: true, if: proc { |t| t.delivery_method == 'email' }
  # REVIEW: validate template content
  # in some cases:
  # ActionController::Base.helpers.sanitize('string') || ActionController::Base.helpers.strip_tags('string')
end
