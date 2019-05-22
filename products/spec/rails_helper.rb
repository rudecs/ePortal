# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'spec_helper'
# Add additional requires below this line. Rails is not loaded until this point!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    # DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.strategy = :deletion
    # DatabaseCleaner.clean_with(:transaction)
    # DatabaseCleaner.clean_with(:truncation)
    # DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do |example|
    if example.metadata[:strategy].present?
      DatabaseCleaner.strategy = example.metadata[:strategy]
    end

    # $redis.flushdb
    DatabaseCleaner.start unless example.metadata[:skip_clean]
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean unless example.metadata[:skip_clean]

    if example.metadata[:strategy].present?
      DatabaseCleaner.strategy = :transaction
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # with.test_framework :minitest
    # with.test_framework :minitest_4
    # with.test_framework :test_unit

    # Choose one or more libraries:
    # with.library :active_record
    # with.library :active_model
    # with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
