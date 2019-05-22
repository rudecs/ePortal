require 'rails_helper'

RSpec.describe 'ProductInstance#handler_price', type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  it 'execute billing code' do
    file = File.read(Rails.root.join('spec/fixtures/usage.json'))
    usage_data = JSON.parse(file)

    code = File.read(Rails.root.join('handler_price.js'))
    js_func = ExecJS.compile("#{code}")
    result = js_func.call('execute_billing_code', usage_data)
    puts JSON.pretty_generate result
  end
end
