# frozen_string_literal: true

require 'rails_helper'

describe Services::Resources::Handle do
  let!(:resource) { create(:machine_resource) }
  let(:event_name) { 'create' }
  let(:started_at) { Time.zone.parse('26.04.2018 13:10:50.123') }
  let(:finished_at) { Time.zone.parse('26.04.2018 13:11:56.999') }
  let(:prms) do
    {
      resource_id: 3,
      resource: 'machine',
      product_id: 2,
      product_instance_id: resource.product_instance_id,
      client_id: 2,
      partner_id: 2,
      event_started_at: '26.04.2018 13:10:50.123',
      event_finished_at: '26.04.2018 13:11:56.999',
      event: event_name,
      memory: 1,
      vcpus: 1,
      boot_disk_size: 1
    }
  end
  let(:service) { described_class.new(prms) }

  describe '#call' do
    let(:event) { double(:event) }
    subject { service.call }

    before do
      service.instance_variable_set(:@resource, resource)
      service.instance_variable_set(:@event, event)
      allow(event).to receive(:create_name?).and_return false # TODO: temp
    end

    it 'should use transaction' do
      expect(Resource).to receive(:transaction)
      subject
    end

    it 'should handle resource attributes' do
      allow(service).to receive(:handle_event_attrs)
      allow(resource).to receive(:save!)
      allow(event).to receive(:save!)
      allow(Services::Payloads::Create).to receive_message_chain(:new, :call)

      expect(service).to receive(:handle_resource_attrs)
      subject
    end

    context 'when save passed' do
      before do
        allow(resource).to receive(:save!).and_return true
        allow(event).to receive(:save!).and_return true
        allow(service).to receive(:handle_resource_attrs)
      end

      it 'should handle event attributes' do
        allow(Services::Payloads::Create).to receive_message_chain(:new, :call).and_return true

        expect(service).to receive(:handle_event_attrs)
        subject
      end

      it 'should call payload service' do
        allow(service).to receive(:handle_event_attrs)

        expect(Services::Payloads::Create).to receive_message_chain(:new, :call)
        subject
      end

      it 'should return true' do
        allow(service).to receive(:handle_event_attrs)
        allow(Services::Payloads::Create).to receive_message_chain(:new, :call).and_return true

        expect(subject).to be_truthy
      end
    end

    context 'when save failed' do
      before do
        allow(service).to receive(:handle_resource_attrs)
        allow(resource).to receive(:save!).and_raise ActiveRecord::RecordInvalid
      end

      it 'should return false' do
        expect(subject).to be_falsey
      end
      # should not save payload
    end
  end

  describe '#handle_event_attrs' do
    let(:event) { double(:event) }
    let(:event_class) { [resource.kind, 'Event'].join.constantize }
    let(:stored_attributes) { event_class.stored_attributes }
    subject { service.send :handle_event_attrs }

    before do
      service.instance_variable_set(:@resource, resource)
      service.instance_variable_set(:@event, event)
    end

    it 'should set event`s resource' do
      allow(event).to receive(:becomes!).with(event_class)
      allow(event_class).to receive(:stored_attributes).and_return(resource_parameters: nil)

      expect(event).to receive(:resource=).with(resource)
      subject
    end

    it 'should typecast event' do
      allow(event).to receive(:resource=).with(resource)
      allow(event_class).to receive(:stored_attributes).and_return(resource_parameters: nil)

      expect(event).to receive(:becomes!).with(event_class)
      subject
    end

    context 'when stored_attributes present' do
      let(:event) { build(:machine_event, resource_parameters: {}) }

      before do
        allow(event).to receive(:resource=).with(resource)
        allow(event).to receive(:becomes!).with(event_class).and_return event
        allow(event_class).to receive(:stored_attributes).and_return(stored_attributes)
      end

      it 'should fill event`s resource_parameters' do
        # TODO: anything = stored_attributes[:resource_parameters].tap { |p| p.to_s + '=' }
        expect(event).to receive(:public_send).with(anything, any_args).exactly(stored_attributes[:resource_parameters].length).times
        subject
      end
    end

    context 'when stored_attributes absent' do
      let(:stored_attributes) do { resource_parameters: nil } end

      before do
        allow(event).to receive(:resource=).with(resource)
        allow(event).to receive(:becomes!).with(event_class)
        allow(event_class).to receive(:stored_attributes).and_return(stored_attributes)
      end

      it 'should leave resource_params empty' do
        expect(event).not_to receive(:public_send)
        subject
      end
    end
  end

  describe '#resource_params' do
    subject { service.send :resource_params }
    let(:event) { double(:event) }
    let(:value) do
      {
        resource_id: prms[:resource_id],
        kind: prms[:resource].to_s.classify,
        partner_id: prms[:partner_id],
        product_id: prms[:product_id],
        product_instance_id: prms[:product_instance_id],
        client_id: prms[:client_id]
      }
    end

    before do
      service.instance_variable_set(:@event, event)
      allow(event).to receive(:create_name?).and_return false
    end

    it { is_expected.to eq value }
  end

  describe '#event_params' do
    subject { service.send :event_params }
    let(:value) do
      {
        name: prms[:event],
        resource_parameters: {},
        started_at: Time.zone.parse(prms[:event_started_at]).to_datetime,
        finished_at: Time.zone.parse(prms[:event_finished_at]).to_datetime
      }
    end
    it { is_expected.to eq value }
  end
end
