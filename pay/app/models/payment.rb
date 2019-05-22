class Payment < ApplicationRecord
  CURRENCIES = %w(rub usd eur).freeze

  belongs_to :client
  belongs_to :user

  validates :amount_cents, :client, :user, presence: true
  validates :amount_cents, numericality: { greater_than_or_equal_to: 100_00 }, allow_nil: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES } # + check client currency? RUB, EUR, USD.
  validates :gateway, presence: true, inclusion: { in: %w[robokassa payu] }
  validate :currency_match, if: proc { |pmt| pmt.currency.present? && pmt.client.present? }

  # based on external service`s response that accepts payments
  scope :paid, -> { where.not(paid_at: nil) }
  scope :unpaid, -> { where(paid_at: nil) }
  # send uncharged to accounting with cron
  scope :charged, -> { where.not(charged_at: nil) }
  scope :uncharged, -> { where(charged_at: nil) }

  def amount
    amount_cents.to_f / 100
  end

  def paid!
    touch :paid_at
  end

  def paid?
    paid_at.present?
  end

  def charged!
    touch :charged_at
  end

  def charged?
    charged_at.present?
  end

  private

  def currency_match
    errors.add(:currency, 'currency mismatch') unless client.currency.casecmp?(currency) # TODO: localization
  end
end
