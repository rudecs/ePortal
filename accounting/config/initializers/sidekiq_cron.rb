if Rails.env.production?
  Sidekiq::Cron::Job.create({
    name: 'PrepareWriteoffs',
    cron: '0 */1 * * *',
    class: 'Writeoff::CreateJob',
    queue: 'high'
  })

  Sidekiq::Cron::Job.create({
    name: 'QueueUnpaid',
    cron: '11,25,45 */1 * * *',
    class: 'Writeoff::QueueUnpaidJob',
    queue: 'high'
  })

  Sidekiq::Cron::Job.create({
    name: 'AlertBlockedClients',
    cron: '0 */19 * * *',
    class: 'Client::BlockingAlertJob',
    queue: 'low'
  })
end
