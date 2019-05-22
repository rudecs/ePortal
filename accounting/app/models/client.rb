# frozen_string_literal: true

class Client < ClientsDbBase
  include Clients::BalanceMethods

  # REVIEW: not sure if it is a good idea. Can be any interval in next release?
  INTERVAL_METHODS = {
    0 => { method: '+', value: 1.hour }, # 1.hour
    1 => { method: 'weeks_since', value: 1 }, # 1.week
    2 => { method: 'weeks_since', value: 2 }, # 2.weeks
    3 => { method: 'next_month', value: 1 } # 1.month
  }.freeze

  # has_many :payments
  has_many :writeoffs
  has_many :payment_transactions
  belongs_to :discount_package, optional: true

  attr_accessor :next_billing_start_date, :next_billing_end_date

  validates :current_balance_cents, :currency, :writeoff_type, presence: true
  # validates :writeoff_date, presence: true # + >= created_at? This is not a concern of Accounting
  validates :writeoff_interval, inclusion: { in: INTERVAL_METHODS.keys }, presence: true, if: proc { |c| c.writeoff_type == 'postpaid' }
  validates :discount_package, presence: true, if: proc { |c| c.discount_package_id.present? }

  # before_update :review_balance, if: :balance_changed?
  # after_commit :apply_balance_change!, on: :update

  scope :active, -> { where(deleted_at: nil) }
  scope :prepaid, -> { where(writeoff_type: 'prepaid') } # Списания происходят каждый учетный период(1 час).
  scope :postpaid, -> { where(writeoff_type: 'postpaid') } # Оплата производится каждый период биллинга, начиная с даты биллинга.

  # deprecated
  # def initialize(*args, &block)
  #   @balance_action_required = nil # TODO: make it private.
  #   super
  # end

  def last_writeoff
    writeoffs.order(:end_date).last
  end

  def discountable?
    discount_package_id.present?
  end

  def soft_deleted?
    deleted_at.present?
  end

  def blocked?
    blocked_at.present? # || status == blocking || blocked || banned? deleted?
  end

  def paid_before_block
    if blocked?
      writeoffs.paid.where('end_date <= ?', blocked_at.end_of_hour).order(:end_date).last
    else
      writeoffs.paid.order(:end_date).last
    end
  end

  def prepaid?
    writeoff_type == 'prepaid'.freeze
  end

  private

  # deprecated
  # def apply_balance_change!
  #   return true if @balance_action_required.nil?
  #   # REVIEW: use Client::ToggleJob kinda thing(looking forward to this)
  #   Services::Clients::Blocker.new(self).public_send(@balance_action_required)
  #   # TODO: rescue to exec other after commit's
  #   # from standard error starts_with? "Code:"
  # end

  # deprecated
  # def review_balance
  #   if balances_sum > 0 && blocked?
  #     @balance_action_required = 'unblock!'
  #   elsif balances_sum <= 0 && !blocked?
  #     @balance_action_required = 'block!'
  #   end
  #   true
  # end

  # def balance_changed?
  #   will_save_change_to_current_balance_cents? || will_save_change_to_current_bonus_balance_cents?
  #   # saved_change_to_attribute? # Rails 5.2 for after_update
  # end

  # private

  # attr_reader :balance_action_required
end
