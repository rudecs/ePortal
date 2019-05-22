# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each) do |example|
    if example.metadata[:type] == :feature
      example.run
      DatabaseCleaner.clean_with :truncation
    else
      DatabaseCleaner.start
      example.run
      DatabaseCleaner.clean
    end
  end
end
