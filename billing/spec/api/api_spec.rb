require 'rails_helper'

RSpec.describe API do
  it 'GET /api/billing/ping return 200' do
    get '/api/billing/ping'
    expect(response).to have_http_status 200
  end
end
