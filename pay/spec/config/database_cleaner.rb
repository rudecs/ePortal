# frozen_string_literal: true

RSpec.configure do |config|
  clients_db_name = CLIENTS_DB['database'].to_sym

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner[:active_record, { connection: clients_db_name }].clean_with(:truncation)
  end

  config.around(:each) do |example|
    if example.metadata[:type] == :feature
      example.run
      DatabaseCleaner.clean_with :truncation
      DatabaseCleaner[:active_record, { connection: clients_db_name }].clean_with(:truncation)
    else
      DatabaseCleaner.start
      DatabaseCleaner[:active_record, { connection: clients_db_name }].start
      example.run
      DatabaseCleaner.clean
      DatabaseCleaner[:active_record, { connection: clients_db_name }].clean
    end
  end
end
