Sidekiq::Cron::Job.create({
  name: 'QueueUncharged',
  cron: '*/5 * * * *',
  class: 'Payment::QueueUnchargedJob'
}) if Rails.env.production?
