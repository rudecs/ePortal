require 'rails_helper'

RSpec.describe ChargeCostByUsageRecord, type: :interactor do
  describe '.call' do
    context 'when passing usage_record correct' do
      let(:product_instance) { create(:product_instance) }

      let(:usage_record) do
        { "client_id" => 111, "product_id" => 222, "product_instance_id" => product_instance.id,
          "memory" => { "count" => 4000 }, "cpu" => { "count" => 10 },
          "start_at" => 1.hours.ago.beginning_of_hour, "end_at" => 1.hour.ago.end_of_hour }
      end

      let(:charge_record_1) { Charge::ProductInstance.first }

      subject(:context) do
        ChargeCostByUsageRecord.call(usage_record: usage_record, resource_type: 'Charge::ProductInstance')
      end

      it 'create charge records' do
        expect(subject).to be_a_success
        expect(Charge::ProductInstance.count).to eq 2
        expect(charge_record_1.client_id).to eq usage_record['client_id']
        expect(charge_record_1.product_id).to eq usage_record['product_id']
        expect(charge_record_1.product_instance_id).to eq usage_record['product_instance_id']
        expect(charge_record_1.resource_id).to eq usage_record['product_instance_id']
        expect(charge_record_1.billing_units_digest).to eq subject.billing_units_digest
        expect(charge_record_1.time_sequence_uid).to eq subject.time_sequence_uid
        expect(charge_record_1.key).to eq 'cpu'
        expect(charge_record_1.count).to eq 10
        expect(charge_record_1.price).to eq 120
        expect(charge_record_1.currency).to eq 'rub'
        expect(charge_record_1.start_at.strftime("%F %T%:z")).to eq usage_record['start_at'].strftime("%F %T%:z")
        expect(charge_record_1.end_at.strftime("%F %T%:z")).to eq usage_record['end_at'].strftime("%F %T%:z")
      end
    end

    context 'when exists previous same charging record' do
      let!(:product_instance) { create(:product_instance, id: 333) }

      let!(:previous_charge_record) { create(:charge_product_instance, start_at: 2.hours.ago.beginning_of_hour, end_at: 2.hour.ago.end_of_hour) }

      let(:usage_record) do
        { "client_id" => 111, "product_id" => 222, "product_instance_id" => 333,
          "memory" => { "count" => 4000 }, "cpu" => { "count" => 10 },
          "start_at" => 1.hours.ago.beginning_of_hour, "end_at" => 1.hour.ago.end_of_hour }
      end

      subject(:context) do
        ChargeCostByUsageRecord.call(usage_record: usage_record, resource_type: 'Charge::ProductInstance')
      end

      it 'create new record with same time_sequence_uid' do
        expect(subject.charge_records.pluck(:time_sequence_uid).uniq).to eq [previous_charge_record.time_sequence_uid]
        expect(subject.charge_records.pluck(:billing_units_digest).uniq).to eq [previous_charge_record.billing_units_digest]
      end
    end

    context 'when exists same charging record but not previous hour' do
      let!(:product_instance) { create(:product_instance, id: 333) }

      let!(:previous_charge_record) { create(:charge_product_instance, start_at: 3.hours.ago.beginning_of_hour, end_at: 3.hour.ago.end_of_hour) }

      let(:usage_record) do
        { "client_id" => 111, "product_id" => 222, "product_instance_id" => 333,
          "memory" => { "count" => 4000 }, "cpu" => { "count" => 10 },
          "start_at" => 1.hours.ago.beginning_of_hour, "end_at" => 1.hour.ago.end_of_hour }
      end

      subject(:context) do
        ChargeCostByUsageRecord.call(usage_record: usage_record, resource_type: 'Charge::ProductInstance')
      end

      it 'create new record with another time_sequence_uid' do
        expect(subject.charge_records.pluck(:time_sequence_uid).uniq).to_not eq [previous_charge_record.time_sequence_uid]
        expect(subject.charge_records.pluck(:billing_units_digest).uniq).to eq [previous_charge_record.billing_units_digest]
      end
    end

    context 'when repeat charge processing for same period' do
      let!(:product_instance) { create(:product_instance, id: 333) }

      let!(:existed_charge_record) { create(:charge_product_instance, key: 'cpu', count: 5, billing_units_digest: 'abc', start_at: 1.hours.ago.beginning_of_hour, end_at: 1.hour.ago.end_of_hour) }
      let!(:existed_charge_record_2) { create(:charge_product_instance, key: 'memory', count: 2000, billing_units_digest: 'abc', start_at: 1.hours.ago.beginning_of_hour, end_at: 1.hour.ago.end_of_hour) }

      let(:usage_record) do
        { "client_id" => 111, "product_id" => 222, "product_instance_id" => 333,
          "memory" => { "count" => 4000 }, "cpu" => { "count" => 10 },
          "start_at" => 1.hours.ago.beginning_of_hour, "end_at" => 1.hour.ago.end_of_hour }
      end

      subject(:context) do
        ChargeCostByUsageRecord.call(usage_record: usage_record, resource_type: 'Charge::ProductInstance')
      end

      it 'existed record rewrited, not duplicated' do
        expect(subject).to be_a_success
        existed_charge_record.reload
        existed_charge_record_2.reload
        expect(Charge::ProductInstance.count).to eq 2
        expect(existed_charge_record.count).to eq 10
        expect(existed_charge_record_2.count).to eq 4000
      end
    end
  end
end
