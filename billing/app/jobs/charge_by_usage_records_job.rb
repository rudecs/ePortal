class ChargeByUsageRecordsJob < ApplicationJob
  queue_as :usage_processing

  def perform(usage_records, grouping, resource_type = ChargeCostForPeriod::DEFAULT_RESOURCE_TYPE)
    result = CalculateBillingUnits.call(usage_records: usage_records, grouping: grouping)
    return $charging_log.error(result.error) unless result.success?

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

    # usage_records.each do |usage_record| # already sorted
    #   result = CalculateBillingUnits.call(usage_record: usage_record, grouping: grouping)
    #   return $charging_log.error(result.error) unless result.success?

    #   result.billing_units.each do |billing_units|
    #     charging_result = ChargeCostByUsageRecord.call({
    #       billing_units: billing_units,
    #       billing_code_version: result.billing_code_version,
    #       usage_record: usage_record,
    #       resource_type: resource_type,
    #       })
    #     if charging_result.failure?
    #       $charging_log.error charging_result.error
    #     end
    #   end
    #   # charging_result = ChargeCostByUsageRecord.call(usage_record: usage_record, resource_type: resource_type)
    #   # if charging_result.failure?
    #   #   $charging_log.error charging_result.error
    #   # end
    # end
  end
end
