# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:current_time) { Time.zone.now.beginning_of_hour }
  let(:event) { create(:machine_event, :resize_event, started_at: current_time - 1.minute, finished_at: current_time - 1.minute) }

  describe 'validations' do
    it { expect(event).to be_valid }
  end

  describe 'scopes' do
    describe '.started_before' do
      subject { described_class.started_before(current_time) }

      context 'when event started before some time' do
        it { is_expected.to include event }
      end

      context 'when event started after some time' do
        let(:event) { create(:machine_event, :create_event, started_at: current_time) } # might be not valid after changes
        it { is_expected.not_to include event }
      end
    end

    describe '.finished_before' do
      subject { described_class.finished_before(current_time) }

      context 'when event finished before some time' do
        it { is_expected.to include event }
      end

      context 'when event finished after some time' do
        let(:event) { create(:machine_event, :create_event, started_at: current_time, finished_at: current_time + 1.minute) }
        it { is_expected.not_to include event }
      end
    end
  end
end
