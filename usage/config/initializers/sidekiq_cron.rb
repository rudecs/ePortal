if Rails.env.production?
  Sidekiq::Cron::Job.create({
    name: 'CreatePayloads',
    cron: '1 */1 * * *',
    class: 'Payload::CreateJob',
    queue: 'default'
  })
end
