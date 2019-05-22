class ChargeCostForPeriod
  include Interactor

  DEFAULT_RESOURCE_TYPE = 'Charge::CloudResource'.freeze
  # DEFAULT_RESOURCE_TYPE = 'Charge::ProductInstance'.freeze

  def call
    $charging_log.info "Start charge processing ..."
    set_period! if period_not_specified?

    result = GetUsageRecords.call(from: context.from, to: context.to, resource_type: resource_type)

    if result.success?
      result.records.group_by { |r| [r['product_instance_id'], r['start_at']] }.each do |grouping, usage_records|
        if context.perform_async
          ChargeByUsageRecordsJob.perform_later(usage_records, grouping, resource_type)
        else
          result = CalculateBillingUnits.call(usage_records: usage_records, grouping: grouping)
          context.fail! error: result.error unless result.success?

          result.billing_units.each do |billing_units|
            charging_result = ChargeCostByUsageRecord.call({
              billing_units: billing_units,
              billing_code_version: result.billing_code_version,
              # usage_record: usage_record,
              resource_type: resource_type,
              mode: :miss_recalculate_existed_records,
            })
            if charging_result.failure?
              $charging_log.error charging_result.error
            end
          end
        end
      end
      # group_by_product_instance_id(result.records).each do |_, usage_records|
      #   if context.perform_async
      #     ChargeByUsageRecordsJob.perform_later(usage_records, resource_type)
      #   else
      #     usage_records.sort_by { |r| r['start_at'] }.each do |usage_record|
      #       result = CalculateBillingUnits.call(usage_record: usage_record)
      #       context.fail! error: result.error unless result.success?
      #       result.billing_units.each do |billing_units|
      #         charging_result = ChargeCostByUsageRecord.call({
      #           billing_units: billing_units,
      #           billing_code_version: result.billing_code_version,
      #           usage_record: usage_record,
      #           resource_type: resource_type,
      #         })
      #         if charging_result.failure?
      #           $charging_log.error charging_result.error
      #         end
      #       end
      #     end
      #   end
      # end
    else
      $charging_log.error result.error
    end
    $charging_log.info 'Finish charge processing ...'
  end

  protected

  def period_not_specified?
    context.to.blank? || context.from.blank?
  end

  def set_period!
    charge_record = find_last_charge_record
    if charge_record
      set_next_interval! charge_record
    else
      set_period_for_first_call!
    end
  end

  def find_last_charge_record
    resource_type.constantize.order(end_at: :desc).first
  end

  def set_next_interval!(charge_record)
    start_at = (charge_record.start_at + 1.hour).beginning_of_hour
    end_at = 1.hour.ago.end_of_hour
    context.from, context.to = start_at, end_at
  end

  def set_period_for_first_call!
    context.from = 1.month.ago.beginning_of_day
    context.to = 1.hour.ago.end_of_hour
  end

  def resource_type
    context.resource_type ||= DEFAULT_RESOURCE_TYPE
  end

  def group_by_product_instance_id(usage_records)
    usage_records.group_by { |r| r['product_instance_id'] }
  end
end
