require 'rails_helper'

RSpec.describe ChargeCostForPeriod, type: :interactor do
  describe '.call' do
    context 'when usage return records' do
      let!(:product_instance) { create(:product_instance, id: 333) }
      let!(:product_instance_2) { create(:product_instance, id: 444) }

      let(:usage_record) do
        { "client_id" => 123, "product_id" => 22, "product_instance_id" => product_instance.id, "cloud_spaces" => { "count" => 10 }, "cpu" => { "count" => 10 }, "start_at" => "2018-04-05 13:00:00 +0300", "end_at" => "2018-04-05 13:59:59 +0300" }
      end

      let(:charge_record_1) { Charge::ProductInstance.first }

      subject(:context) do
        VCR.use_cassette('get_usage_records_success') do
          ChargeCostForPeriod.call(from: "2018-05-07 10:00:00 UTC", to: "2018-05-07 10:59:59 UTC", resource_type: 'Charge::ProductInstance')
        end
      end

      it 'create charge records' do
        expect(subject).to be_a_success
        expect(Charge::ProductInstance.count).to eq 4
      end
    end
  end
end
