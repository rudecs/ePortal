# frozen_string_literal: true

class Payment < ApplicationRecord
  include Monetizable
  monetize :amount

  belongs_to :client
  has_one :payment_transaction, as: :subject

  # -state, -description
  validates :client, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :source, presence: true, inclusion: { in: %w(redeeming payment new_registration admin) }
  validates :puid, presence: true, uniqueness: { scope: :source }, if: proc { |pt| pt.source.present? }
  validate  :currency_missmatch, if: proc { |pt| pt.client.present? && pt.currency.present? }

  private

  def currency_missmatch
    errors.add(:currency, 'currencies do not match') unless client.currency.casecmp?(currency)
  end
end
