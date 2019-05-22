# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rspec/retry'
require 'sidekiq/testing'
require_relative 'support/rspec_boolean_matcher'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def log(data)
  puts '============='
  puts data
  puts '============='
end
