require 'rails_helper'

RSpec.describe V1::ProductInstancesResource do
  describe 'POST /product_instances/:id' do
    let(:params) do
      { product_instance: { code: 'some code', lang: 'js' } }
    end
    it 'return updated product_instance' do
      post "/api/billing/v1/product_instances/1234", params: params
      expect(response).to have_http_status 201
      expect(JSON.parse(response.body)).to include({ 'product_instance' => { 'id' => 1234, 'code' => 'some code', 'lang' => 'js' } })
    end
  end
end
