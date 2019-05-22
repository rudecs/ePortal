class PaymentTransaction < ApplicationRecord
  include Monetizable
  monetize :amount

  belongs_to :client
  belongs_to :subject, polymorphic: true

  validates :amount, :client, :subject, presence: true
  validates :amount, exclusion: { in: [0] } # , allow_nil: true
  validates :account_type, presence: true, inclusion: { in: %w[money bonus] }
  validates :subject_id, uniqueness: { scope: :subject_type }, if: proc { |pt| pt.subject.present? && pt.subject.is_a?(Payment) }
  validates :subject_id, uniqueness: { scope: %i[subject_type account_type] }, if: proc { |pt| pt.subject.present? && pt.subject.is_a?(Writeoff) }
  validates :currency, presence: true
  validate :currency_missmatch, if: proc { |pt| pt.client.present? && pt.currency.present? }

  private

  # === Validations ===
  def currency_missmatch
    errors.add(:currency, 'currencies do not match') unless client.currency.casecmp?(currency)
  end
end
