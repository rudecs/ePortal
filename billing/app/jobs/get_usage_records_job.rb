class GetUsageRecordsJob < ApplicationJob
  queue_as :default

  def perform(resource_type = ChargeCostForPeriod::DEFAULT_RESOURCE_TYPE)
    ChargeCostForPeriod.call(resource_type: resource_type, perform_async: true)
  end
end
