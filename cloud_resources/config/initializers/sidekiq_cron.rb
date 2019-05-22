Sidekiq.options[:poll_interval] = 10

Sidekiq::Cron::Job.create({
  name: 'DeliverEventsJob',
  cron: '*/20 * * * * *',
  class: 'DeliverEventsJob'
})
