require 'rails_helper'

RSpec.describe V1::ChargesResource do
  describe 'GET /charges' do
    let(:params) do
      { charges: { client_id: 111, from: 3.hours.ago.beginning_of_hour, to: DateTime.now } }
    end

    before do
      create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts_1', key: 'cpu', start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hours.ago.end_of_hour)
      create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts_1', key: 'memory', count: 2000, price: 60, start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hours.ago.end_of_hour)
      create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts_1', key: 'cpu', start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hours.ago.end_of_hour)
      create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts_1', key: 'memory', count: 2000, price: 60, start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hours.ago.end_of_hour)
      create(:charge_product_instance, time_sequence_uid: 'ts_2', key: 'cpu')
      create(:charge_product_instance, time_sequence_uid: 'ts_2', key: 'memory', count: 4000, price: 100)
    end

    it 'return aggregated data' do
      get "/api/billing/v1/charges", params: params
      expect(JSON.parse(response.body)['data']).to eq (
        [{"product_id"=>222,
          "product_instance_id"=>333,
          "billing_data"=>
           {"cpu"=>{"count"=>10.0, "price"=>200.00, "currency"=>"rub"},
            "memory"=>{"count"=>2000.0, "price"=>120.00, "currency"=>"rub"}},
          "start_at"=>3.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
          "end_at"=>2.hours.ago.end_of_hour.strftime("%F %T%:z")},
         {"product_id"=>222,
          "product_instance_id"=>333,
          "billing_data"=>
           {"cpu"=>{"count"=>10.0, "price"=>100.00, "currency"=>"rub"},
            "memory"=>{"count"=>4000.0, "price"=>100.00, "currency"=>"rub"}},
          "start_at"=>1.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
          "end_at"=>1.hour.ago.end_of_hour.strftime("%F %T%:z")}]
      )
    end
  end
end
