# frozen_string_literal: true

require 'rails_helper'

describe Services::Billing::Request do
  let!(:writeoff) { create(:unpaid_writeoff) }
  let(:service) { described_class.new(writeoff.id) }

  describe '#call' do
    subject { service.call }

    before do
      service.instance_variable_set(:@writeoff, writeoff)
    end

    it 'should make request' do
      expect(service).to receive(:request_billing_data)
      subject
    end

    context 'when successful request' do
      before do
        allow(service).to receive(:request_billing_data).and_return('data' => [{}, {}]) # TODO: stub resp/chain
      end

      it { is_expected.not_to be_falsey }
    end

    context 'when request failed' do
      it 'should return false' do
        allow(service).to receive(:request_billing_data).and_raise StandardError.new

        expect(subject).to be_falsey
      end

      it 'should return false' do
        allow(service).to receive(:request_billing_data).and_return []

        expect(subject).to be_falsey
      end
    end
  end

  describe '#request_billing_data' do
    let(:url) { double(:url) }
    subject { service.send(:request_billing_data) }

    context 'when url present' do
      before do
        allow(service).to receive(:billing_url).and_return url
        allow(Faraday).to receive_message_chain(:get, :body).and_return '[]'
      end

      it 'should use Faraday to make request' do
        allow(JSON).to receive(:parse)

        expect(Faraday).to receive(:get)
        subject
      end

      it 'should try to parse resp' do
        expect(JSON).to receive(:parse)
        subject
      end
    end

    context 'when no url provided' do
      before do
        allow(service).to receive(:billing_url).and_return false
      end

      it 'should raise exception' do
        expect { subject }.to raise_error(RuntimeError, 'billing is not avaliable')
      end
    end
  end

  describe '#billing_url' do
    let(:diplomat) { OpenStruct.new(Address: 'localhost', ServicePort: '3000') }
    subject { service.send(:billing_url) }

    it 'should use Diplomat to get billing service info' do
      expect(Diplomat::Service).to receive(:get).with('billing')
      subject
    end

    context 'when address present' do
      before do
        allow(Diplomat::Service).to receive(:get).with('billing').and_return diplomat
      end

      it 'should return url' do
        expect(subject).to be_truthy
      end
    end

    context 'when address absent' do
      before do
        allow(Diplomat::Service).to receive(:get).with('billing').and_return nil
      end

      it 'should return false' do
        expect(subject).to be_falsey
      end
    end
  end
end
