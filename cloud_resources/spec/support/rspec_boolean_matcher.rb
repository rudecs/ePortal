# https://gist.github.com/koriroys/531c84e1491fe42b3aaa

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