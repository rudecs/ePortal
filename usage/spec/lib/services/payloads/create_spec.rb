# frozen_string_literal: true

require 'rails_helper'

describe Services::Payloads::Create do
  let!(:resource) { create(:machine_resource) }
  let!(:event) { create(:machine_event, :resize_event) }
  let(:fake_period) { [Time.zone.now, Time.zone.now] }
  let(:billing_period) { fake_period } # ???
  let(:options) do
    { billing_period: fake_period }
  end
  let(:service) { described_class.new(resource, event) }

  describe '#call' do
    let(:payload) { double(:payload) }
    subject { service.call }

    before do
      service.instance_variable_set(:@payload, payload)
      allow(service).to receive(:payload_params)
      allow(payload).to receive(:assign_attributes)
    end

    after { subject }
    it { expect(payload).to receive(:save!) }
  end

  describe '#billing_period' do
    subject { service.send(:billing_period) }

    before do
      service.instance_variable_set(:@billing_period, billing_period)
      service.instance_variable_set(:@options, options)
      service.instance_variable_set(:@event, event)
      # stub_const('Event::START_TIME_EVENTS', %w[resize delete])
      # allow(Event::START_TIME_EVENTS).to receive(:include?).with(event.name).and_return true
    end

    context 'when billing period is already set' do
      it { expect(subject).to eq billing_period }
    end

    context 'when billing period is not set and option billing_period present' do
      let(:billing_period) { nil }
      it { expect(subject).to eq options[:billing_period] }
    end

    context 'when billing period is not set and option billing_period blank' do
      # resize event use-case.
      let(:billing_period) { nil }
      let(:options) { {} }

      after { subject }
      it { expect(service).to receive(:period).with(event.started_at) }
    end
  end

  describe '#period' do
    subject { service.send(:period, event.started_at) }

    it { expect(subject).to eq [event.started_at.beginning_of_hour, event.started_at.end_of_hour] }
  end

  describe '#chargable' do
  end

  describe '#chargable_params' do
  end

  describe '#payload_params' do
    let(:value) do
      {
        resource_id: resource.id,
        # chargable:,
        period_start: options[:billing_period].first,
        period_end: options[:billing_period].last
      }
    end
  end
end
