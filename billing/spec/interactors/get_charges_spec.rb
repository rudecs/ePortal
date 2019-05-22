require 'rails_helper'

RSpec.describe GetCharges, type: :interactor do
  describe '.call' do
    context 'when charge records exist for client_id' do
      subject(:context) { GetCharges.call(client_id: 111, from: 3.hours.ago.beginning_of_hour, to: DateTime.now) }
      before do
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts1', key: 'cpu', start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hours.ago.end_of_hour)
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts1', key: 'memory', count: 2000, price: 60, start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hours.ago.end_of_hour)
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts1', key: 'cpu', start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hours.ago.end_of_hour)
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts1', key: 'memory', count: 2000, price: 60, start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hours.ago.end_of_hour)
        create(:charge_product_instance, key: 'cpu', time_sequence_uid: 'ts2')
        create(:charge_product_instance, key: 'memory', time_sequence_uid: 'ts2', count: 4000, price: 100)
      end

      it 'return aggregated data' do
        expect(subject).to  be_a_success
        expect(subject.charging_data).to eq [{"product_id"=>222,
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
      end
    end

    context 'when charges have different time_sequence_uid' do
      subject(:context) { GetCharges.call(client_id: 111, from: 5.hours.ago.beginning_of_hour, to: DateTime.now) }
      before do
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts1', start_at: 5.hours.ago.beginning_of_hour, end_at: 5.hours.ago.end_of_hour)
        create(:charge_product_instance, billing_units_digest: 'aaa', time_sequence_uid: 'ts2', start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hours.ago.end_of_hour)
        create(:charge_product_instance, count: 20, price: 200, billing_units_digest: 'bbb', time_sequence_uid: 'ts3', start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hours.ago.end_of_hour)
        create(:charge_product_instance, count: 20, price: 200, billing_units_digest: 'bbb', time_sequence_uid: 'ts3', start_at: 1.hours.ago.beginning_of_hour, end_at: 1.hours.ago.end_of_hour)
      end

      it 'return correct aggregated data' do
        expect(subject).to  be_a_success
        expect(subject.charging_data).to eq [{"product_id"=>222,
                                              "product_instance_id"=>333,
                                              "billing_data"=>
                                               {"cpu"=>{"count"=>10.0, "price"=>100.00, "currency"=>"rub"}},
                                              "start_at"=>5.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
                                              "end_at"=>5.hours.ago.end_of_hour.strftime("%F %T%:z")},
                                             {"product_id"=>222,
                                              "product_instance_id"=>333,
                                              "billing_data"=>
                                               {"cpu"=>{"count"=>10.0, "price"=>100.00, "currency"=>"rub"}},
                                              "start_at"=>3.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
                                              "end_at"=>3.hours.ago.end_of_hour.strftime("%F %T%:z")},
                                             {"product_id"=>222,
                                              "product_instance_id"=>333,
                                              "billing_data"=>
                                               {"cpu"=>{"count"=>20.0, "price"=>400.00, "currency"=>"rub"}},
                                              "start_at"=>2.hours.ago.beginning_of_hour.strftime("%F %T%:z"),
                                              "end_at"=>1.hour.ago.end_of_hour.strftime("%F %T%:z")}]
      end
    end
  end
end
