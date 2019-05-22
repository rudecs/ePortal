# frozen_string_literal: true

module Services
  module Writeoffs
    class Result
      attr_reader :writeoff, :client
      PARAMS =
        [
          {
            "product_id"=>222,
            "product_instance_id"=>333,
            "billing_data"=>
              {
                "cpu"=>{"count"=>10.0, "price"=>200.00, "currency"=>"rub"},
                "memory"=>{"count"=>2000.0, "price"=>120.00, "currency"=>"rub"}
              },
            "start_at"=>3.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
            "end_at"=>2.hours.ago.end_of_hour.strftime("%F %T%:z")
          },
          {
            "product_id"=>222,
            "product_instance_id"=>333,
            "billing_data"=>
            {
              "cpu"=>{"count"=>10.0, "price"=>100.00, "currency"=>"rub"},
              "memory"=>{"count"=>4000.0, "price"=>100.00019, "currency"=>"rub"}
            },
            "start_at"=>1.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
            "end_at"=>1.hour.ago.end_of_hour.strftime("%F %T%:z")
          },
          {
            "product_id"=>333,
            "product_instance_id"=>444,
            "billing_data"=>
            {
              "cpu"=>{"count"=>10.0, "price"=>100.00, "currency"=>"rub"},
              "memory"=>{"count"=>4000.0, "price"=>100.00, "currency"=>"rub"}
            },
            "start_at"=>1.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
            "end_at"=>1.hour.ago.end_of_hour.strftime("%F %T%:z")
          }
        ].freeze

      def initialize(writeoff, charges)
        # TODO: @charges = charges
        @charges = Rails.env.production? ? charges : PARAMS
        @writeoff = writeoff
        @client = @writeoff.client
      end

      def charge!
        # complete task if writeoff is already paid
        return true if @writeoff.paid? # already paid means success? false? exception? or let @writeoff.paid! handle this(not implemented)
        prices = prices_before_and_after_discount # returns array: +[price with discount, without]+
        @writeoff.tap do |w|
          w.amounts_to_pay(prices.first, prices.second) # currency is already set on create!
          w.to_processed
        end

        # 1 transaction per db
        Writeoff.transaction do
          Client.transaction(requires_new: true) do
            @writeoff.save! # save anyway?
            ProductInstanceState.create!(@charges) { |pis| pis.writeoff = @writeoff } # REVIEW: should i extra check their start_at and end_at to fit Writeoff?
            @writeoff.paid! # also handles presence of amount
            unless @writeoff.amount.zero?
              # make two charges. first try bonus account, rest amount on money acc.
              # current_bonus_balance_cents >= 0 constraint in db
              current_bonus_balance = @client.payment_transactions.where(account_type: 'bonus').sum(:amount) # * 100).to_i
              if current_bonus_balance > 0
                # charge client
                bonus_acc = current_bonus_balance - @writeoff.amount
                if @client.charge(bonus_acc < 0 ? -current_bonus_balance : -@writeoff.amount, { subject: @writeoff, account_type: 'bonus' })
                  money_acc = bonus_acc < 0 ? bonus_acc : 0
                  if money_acc < 0
                    raise 'failed to charge client' unless @client.charge(money_acc, { subject: @writeoff, account_type: 'money' })
                  end
                else
                  # try to make full money transaction? bad idea?!
                  raise 'calculation error cause of race conditions, not enough bonus-balance'
                end
              else
                raise 'failed to charge client' unless @client.charge(-@writeoff.amount, { subject: @writeoff, account_type: 'money' })
              end
              #
              #
              # BEFORE splitting to bonus and money accounts
              # raise 'failed to charge client' unless @client.charge(-@writeoff.amount, { subject: @writeoff })
            end
            true
          end
        end
      rescue
        false
      end

      def predict_blocking(lpw) # lpw: last paid writeoff
        # TODO: return unless predictable?
        return unless @client.state == 'active'
        return if !lpw.paid? || lpw.amount&.zero?
        return if @client.last_threshold_at.present? && (Time.current - @client.last_threshold_at.beginning_of_hour) < 86_400
        expences = 169 * lpw.amount # arguable 1.hour, depends on implementation of blocking
        avaliable_amount = @client.balances_sum
        if avaliable_amount <= expences # amount is a decimal?!
          DeNotifier::V1::Client.new('accounting').create_notification_request({
            key: :balance_threshold,
            client_ids: [@client.id],
            provided_data: {
              days_left: (avaliable_amount / lpw.amount / 24).to_i,
            },
          })
          @client.touch :last_threshold_at
        end
      end

      private

      def price_before_discount
        currency = @writeoff.currency
        @charges.sum do |charge|
          raise 'billing_data is missing' unless charge['billing_data']&.keys&.any?
          charge['billing_data'].sum do |_unit, value| # unit = (cpu, memory ...)
            raise 'invalid currency' unless value['currency'].to_s.casecmp?(currency)
            value['price'].to_d
          end
        end
      end

      def prices_before_and_after_discount
        if @charges.empty?
          [0, 0]
        elsif @client.discountable?
          apply_discount
        else
          pbd = price_before_discount
          [pbd, pbd]
        end
      end

      # Returns array: price with discount and without.
      # Can possibly 'early return' two prices without discounts if no discounts found
      def apply_discount
        # TODO: after discount_sets currency implementation:
        # discount_sets.where(amount_type: 'fixed', currency: client_currency).or.where(amount_type: 'percent')
        discounts = @client.discount_package&.discount_sets&.includes(:discount)
        if discounts.blank?
          pbd = price_before_discount
          return [pbd, pbd]
        end

        # handle fixed discounts with different currencies(not implemented yet)
        discountable_keys = discounts.each_with_object({}) do |ds, result|
          result[ds.discount.key_name] = ds # if !ds.fixed? || ds.currency.to_s.casecmp?(currency) OR == @writeoff.currency
        end

        without, with = 0, 0
        # return sum of prices by billing key
        billing_units = Hash.new { |hash, key| hash[key] = {} }
        @charges.each do |charge|
          raise 'billing_data is missing' unless charge['billing_data']&.keys&.any?
          charge['billing_data'].each_pair do |billing_key, billing_value|
            billing_units[billing_key] = billing_units[billing_key].merge(billing_value) do |k, a_value, b_value|
              if k == 'currency'
                raise 'currency does not match' if a_value != b_value
                b_value
              else
                a_value.to_d + b_value.to_d
              end
            end
          end
        end

        # sum of billing keys' sum and apply discount for every key
        currency = @writeoff.currency
        billing_units.each do |unit, value|
          raise 'currency does not match' unless value['currency'].to_s.casecmp?(currency)
          discount = discountable_keys[unit]

          price = value['price'].to_d
          without += price

          # FIX: fixed discounts are not allowed for now.
          case discount&.amount_type
          when 'percent'
            price -= discount.amount / 100 * price
            with += price
          when 'quantity' # quantity per hour. Only applicable to MANDATORY cloud_space
            hours = ((@writeoff.end_date - @writeoff.start_date) / 1.hour).to_i + 1 # + 1 cause of end_of_hour
            price -= ((price / value['count']) * discount.amount * hours) if value['count'] > 0
            with += price < 0 ? 0 : price
          when 'fixed'
            price -= discount.amount
            with += price < 0 ? 0 : price
          else
            with += price
          end
        end

        [without, with]
      end
    end
  end
end
