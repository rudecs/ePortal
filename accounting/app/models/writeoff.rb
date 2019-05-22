# frozen_string_literal: true

class Writeoff < ApplicationRecord
  include Monetizable
  # options are not implemented in this release
  monetize :amount, :initial_amount, { precision: 4, rounding_mode: 2 } # BigDecimal::ROUND_DOWN = 2

  belongs_to :client
  has_many :payment_transactions, as: :subject
  has_many :product_instance_states, dependent: :destroy

  validates :start_date, :end_date, presence: true
  validates :start_date, uniqueness: { scope: %i[client_id end_date] }, if: proc { |w| w.client_id && w.start_date && w.end_date }
  validates :amount, :initial_amount, presence: true, if: proc { |w| w.paid? }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: proc { |w| w.amount.present? } # greater_than_or_equal_to
  validates :initial_amount, numericality: { greater_than_or_equal_to: 0 }, if: proc { |w| w.initial_amount.present? } # greater_than_or_equal_to
  validate :discounted_and_initial, if: proc { |w| w.amount.present? && w.initial_amount.present? }
  validate :currency_missmatch, if: proc { |w| w.client.present? && w.currency.present? }
  validate :starts_after_prev, if: proc { |w| w.start_date.acts_like?(Time) && w.client.present? }
  validate :start_greater_end, if: proc { |w| w.start_date.acts_like?(Time) && w.end_date.acts_like?(Time) }

  scope :paid, -> { where.not(paid_at: nil) }
  scope :unpaid, -> { where(paid_at: nil) }

  def paid!
    # raise 'already paid' if paid?
    raise 'amounts should present' unless initial_amount.present? && amount.present?
    touch :paid_at # if client.charge(-amount, { subject: self })
  end

  def paid?
    paid_at.present?
  end

  def amounts_to_pay(initial, discounted)
    raise 'amounts should present' unless initial.present? && discounted.present?
    self.initial_amount = initial
    self.amount = discounted
  end

  # possibly this should be handled by state machine method. state = processed?
  def to_processed
    self.state = 'processed'
  end

  private

  # === Validations ===
  def starts_after_prev
    prev = client.last_writeoff
    errors.add(:start_date, 'should start right after previous writeoff') if prev && start_date == (prev.end_date + 1.hour).beginning_of_hour
  end

  def start_greater_end
    errors.add(:end_date, 'less than start date') unless end_date > start_date
  end

  def currency_missmatch
    errors.add(:currency, 'currencies do not match') unless client.currency.casecmp?(currency)
  end

  def discounted_and_initial
    errors.add(:amount, 'greater than initial amount') if amount > initial_amount
  end
end
