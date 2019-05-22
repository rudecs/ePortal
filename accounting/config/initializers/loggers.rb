$activity_logger = DeActivityLogger::Logger.instance
$billing_requests_log = Logger.new("#{Rails.root}/log/billing_requests_log.log")
$blocker_log = Logger.new("#{Rails.root}/log/blocker.log")
