# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resource, type: :model do
  let(:deleted_at) { nil }
  let(:resource) { create(:machine_resource, deleted_at: deleted_at) }

  let(:current_time) { Time.zone.now } # should be beginning_of_hour
  let!(:event) { create(:machine_event, :create_event, resource: resource, started_at: current_time - 3.minutes, finished_at: current_time - 1.minute) }

  describe 'validations' do
    it { expect(resource).to be_valid }
  end

  describe 'scopes' do
    describe '.active' do
      subject { described_class.active }

      context 'when resource is active' do
        it { is_expected.to include resource }
      end

      context 'when resource is deleted' do
        let(:resource) { create(:machine_resource, :deleted) }
        it { is_expected.not_to include resource }
      end
    end
  end

  describe '#soft_deleted?' do
    subject { resource.soft_deleted? }
    context 'when resource is active' do
      it 'should return FALSE' do
        expect(subject).to be_falsey
      end
    end
    context 'when resource is NOT active' do
      let(:deleted_at) { Time.zone.now }
      it 'should return TRUE' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#last_event_before' do
    subject { resource.last_event_before(current_time) }
    context 'when late create_event.finished_at > resize_event.started_at' do
      let!(:event) { create(:machine_event, :resize_event, resource: resource, started_at: current_time - 2.minutes, finished_at: current_time) }
      it { is_expected.to eq event }
    end

    context 'when delete event present' do
      let!(:event) { create(:machine_event, :delete_event, resource: resource, started_at: current_time - 1.minute, finished_at: current_time) }
      it { is_expected.to eq event }
    end
  end
end
