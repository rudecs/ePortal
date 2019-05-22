require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DePortalPrototype
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq

    # config.time_zone = 'Moscow'
    # config.time_zone = "UTC"
    # config.active_record.default_timezone = :utc

    # config.middleware.insert_before 0, CatchConnectionErrors

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
