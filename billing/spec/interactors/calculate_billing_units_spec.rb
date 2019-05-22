require 'rails_helper'

RSpec.describe CalculateBillingUnits, type: :interactor do
  describe '.call' do
    context 'when billing_code return billing_units' do
      let(:product_instance) { create(:product_instance) }
      let(:usage_record) do
        { "client_id" => 123, "product_id" => 22, "product_instance_id" => product_instance.id, "cloud_spaces" => { "count" => 10 }, "cpu" => { "count" => 10 }, "start_at" => "2018-04-05 13:00:00 +0300", "end_at" => "2018-04-05 13:59:59 +0300" }
      end

      subject { CalculateBillingUnits.call(usage_record: usage_record) }

      it 'succeeds' do
        expect(subject).to be_a_success
        expect(subject.billing_units).to include('cpu' => { 'count' => 10, 'price' => 120, 'currency' => 'rub' },  'memory' => { 'count' => 4000, 'price' => 100, 'currency' => 'rub' } )
      end
    end

    context 'when use production billing_code' do
      let(:billing_code) {create(:billing_code_version, :with_code_by_production)}
      let(:product_instance) { create(:product_instance) }
      let(:usage_record) do
        {
          "machines" => {
              "resources_count" => 1,
              "vcpus" => 1,
              "memory" => 1024,
              "boot_disk_size" => 10
          },
          "start_at" => "2018-04-05 13:00:00 +0300",
          "end_at" => "2018-04-05 13:59:59 +0300",
          "client_id" => 123,
          "product_instance_id" => product_instance.id,
          "product_id" => 22
        }
      end

      before do
        product_instance.update(current_billing_code_version_id: billing_code.id)
        product_instance.reload
      end

      subject { CalculateBillingUnits.call(usage_record: usage_record) }

      it 'succeeds' do
        expect(subject).to be_a_success
        expect(subject.billing_units).to include(
          "cpu"=>{"count"=>10, "price"=>120, "currency"=>"rub"},
          "memory" => {"count"=>4000, "price"=>100, "currency"=>"rub"}
        )
      end
    end
  end
end
