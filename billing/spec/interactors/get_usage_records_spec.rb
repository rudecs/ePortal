require 'rails_helper'

RSpec.describe GetUsageRecords, type: :interactor do
  describe '.call' do
    context 'when usage return correct records' do
      subject(:context) do
        VCR.use_cassette('get_usage_records_success') do
          GetUsageRecords.call(from: "2018-05-07 10:00:00 UTC", to: "2018-05-07 10:59:59 UTC", resource_type: 'Charge::ProductInstance')
        end
      end

      it 'succeeds' do
        expect(subject).to be_a_success
      end

      it 'return records' do
        expect(subject.records.count).to eq 2
        expect(subject.records.map { |r| r['product_instance_id'] }).to match_array [333, 444]
      end
    end
  end
end
