# frozen_string_literal: true

module Clients
  module BalanceMethods
    extend ActiveSupport::Concern

    def current_balance
      current_balance_cents.to_f / 100 # FIX: amount_cents => amount?
    end

    def balances_sum
      (current_balance_cents + current_bonus_balance_cents).to_f / 100
    end

    def charge(amount_value, options = {})
      Services::Balance::Charge.new(self, amount_value, options).call
    end

    def update_balance(account_type)
      # update_column :current_balance_cents, payment_transactions.sum(:amount)
      account_type ||= 'money'
      column_name = account_type == 'money' ? 'current_balance_cents' : 'current_bonus_balance_cents'
      # use update_attribute to invoke callbacks!!!
      update_column column_name, (payment_transactions.where(account_type: account_type).sum(:amount) * 100).to_i
    end
  end
end
