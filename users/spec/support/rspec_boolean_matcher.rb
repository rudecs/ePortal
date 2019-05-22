# https://gist.github.com/Kroid/ee6e509bd91acaa1907b78fc56b2147d

require 'rspec/expectations'

RSpec::Matchers.define :be_boolean do
  match do |actual|
    [true, false].include? actual
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be a boolean(true or false)"
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be not be a boolean(true or false)"
  end

  description do
    "be a boolean(true or false)"
  end
end
