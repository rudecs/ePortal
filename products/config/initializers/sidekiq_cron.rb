Sidekiq.options[:poll_interval] = 10

Sidekiq::Cron::Job.create({
  name: 'ProductInstanceJob::ManageJob',
  cron: '*/30 * * * * *',
  class: 'ProductInstanceJob::ManageJob'
})

# Sidekiq::Cron::Job.create({
#   name: 'ProductInstance::FindDisabledJob',
#   cron: '0 */1 * * *',
#   class: 'ProductInstance::FindDisabledJob'
# })

# Sidekiq::Cron::Job.create({
#   name: 'ProductInstanceReloadCron',
#   cron: '*/10 * * * * *',
#   class: 'ProductInstance::ReloadProcessingJob'
# })
