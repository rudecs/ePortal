# frozen_string_literal: true

module Services
  module Writeoffs
    class Create
      def initialize(task_start_time)
        @task_start_time = task_start_time.beginning_of_hour
      end

      def call
        add_default_discount
        # Client.includes(:writeoffs)
        Client.find_each(batch_size: 100) do |client|
          # loop over batch inside Writeoff.transaction

          # create_writeoffs send("handle_#{client.writeoff_type.downcase}", client)
          create_writeoffs client.prepaid? ? handle_prepaid(client) : handle_postpaid(client)
          # client.prepaid? ? handle_prepaid(client) : handle_postpaid(client) # array implementation
        end
        true
      rescue
        false
      end

      private

      def create_writeoffs(enum)
        writeoffs = enum.to_a
        Writeoff.transaction do
          Writeoff.create!(writeoffs)
        end if writeoffs.any?
        true
      rescue
        # write to fail_log
        false
      end

      # array implementation
      # def create_writeoffs(writeoffs)
      #   Writeoff.transaction do
      #     Writeoff.create!(writeoffs)
      #     true
      #   end if writeoffs.any?
      #   true
      # rescue
      #   # write to fail_log
      #   false
      # end

      def add_default_discount
        default_vdc_discount_id = DiscountPackage.find_by_name('VDC default'.freeze)&.id
        Client.where(discount_package_id: nil).in_batches(of: 100).update_all(discount_package_id: default_vdc_discount_id) if default_vdc_discount_id.present?
      end

      def handle_prepaid(client, &block)
        # wfs = []
        # prev_writeoff = nil
        # loop do
        #   force_creating =
        #     if prev_writeoff.present? || client.writeoffs.any?
        #       last_writeoff = prev_writeoff || client.last_writeoff.end_date

        #       client.next_billing_end_date = last_writeoff + 1.hour
        #       client.next_billing_start_date = (last_writeoff + 1.hour).beginning_of_hour
        #       deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date
        #     else
        #       client.next_billing_start_date = client.created_at # REVIEW: important!!! created_at?
        #       client.next_billing_end_date = client.next_billing_start_date.end_of_hour
        #       deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date && client.next_billing_end_date >= client.next_billing_start_date
        #     end
        #   # prev_writeoff ||= OpenStruct.new # use date instead!
        #   if force_creating
        #     wfs << hash_map(client)
        #     prev_writeoff = client.next_billing_end_date
        #   else
        #     break
        #   end
        # end
        # create_writeoffs(wfs)
        Enumerator.new do |yielder|
          prev_writeoff = nil
          loop do
            force_creating =
              if prev_writeoff.present? || client.writeoffs.exists?
                last_writeoff = prev_writeoff || client.last_writeoff.end_date

                client.next_billing_end_date = last_writeoff + 1.hour
                client.next_billing_start_date = (last_writeoff + 1.hour).beginning_of_hour
                deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date
              else
                client.next_billing_start_date = client.created_at # REVIEW: important!!! created_at?
                client.next_billing_end_date = client.next_billing_start_date.end_of_hour
                deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date && client.next_billing_end_date >= client.next_billing_start_date
              end
            # prev_writeoff ||= OpenStruct.new # use date instead!
            if force_creating
              yielder << hash_map(client)
              prev_writeoff = client.next_billing_end_date
            else
              break
            end
          end
        end.each(&block)
      end

      def handle_postpaid(client, &block)
        Enumerator.new do |yielder|
          interval = Client::INTERVAL_METHODS[client.writeoff_interval] # common per client
          prev_writeoff = nil

          loop do
            force_creating =
              if prev_writeoff.present? || client.writeoffs.exists?
                last_writeoff = prev_writeoff || client.last_writeoff.end_date
                client.next_billing_end_date = last_writeoff.public_send(interval[:method], interval[:value]).end_of_hour

                # monthly or yearly kinda values case
                calc_day_of_month!(client) if client.writeoff_interval == 3

                client.next_billing_start_date = (last_writeoff + 1.hour).beginning_of_hour
                deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date && @task_start_time > last_writeoff
              else
                client.next_billing_start_date = (client.writeoff_date.presence || client.created_at).beginning_of_hour
                client.next_billing_end_date = client.writeoff_interval.zero? ? client.next_billing_start_date.end_of_hour : client.next_billing_start_date.public_send(interval[:method], interval[:value]).end_of_hour
                deletion_impact_absent?(client) && @task_start_time > client.next_billing_end_date # order matters here!
              end
            if force_creating
              yielder << hash_map(client)
              # prev_writeoff ||= OpenStruct.new
              prev_writeoff = client.next_billing_end_date
            else
              break
            end
          end
        end.each(&block)
      end

      def hash_map(client)
        {
          client_id: client.id,
          start_date: client.next_billing_start_date,
          end_date: client.next_billing_end_date,
          state: 'pending'.freeze,
          currency: client.currency
        }
      end

      def deleted_greater_than_end_date?(client)
        return true unless client.soft_deleted?
        client.deleted_at.end_of_hour >= client.next_billing_end_date
      end

      def deletion_impact_absent?(client)
        return true if deleted_greater_than_end_date?(client)
        client.next_billing_end_date = client.deleted_at # assign new end_date!
        client.next_billing_end_date >= client.next_billing_start_date # >?
      end

      def calc_day_of_month!(client)
        writeoff_day = client.writeoff_date&.day || client.created_at.day # common per client
        day_of_month_to_set =
          if writeoff_day <= client.next_billing_end_date.day
            writeoff_day
          else
            max_in_month = Time.days_in_month(client.next_billing_end_date.month, client.next_billing_end_date.year)
            max_in_month > writeoff_day ? writeoff_day : max_in_month
          end
        client.next_billing_end_date = client.next_billing_end_date.change(day: day_of_month_to_set)
      end
    end
  end
end
