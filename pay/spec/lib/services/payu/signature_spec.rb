# frozen_string_literal: true

require 'rails_helper'

describe Services::Payu::Signature do
  let(:service) { described_class.new({}) }

  describe '#call' do
    let(:source) { double(:source) }
    subject { service.call }

    before do
      allow(service).to receive(:bytesized_hash).and_return source
    end

    it 'should use MD5 for encoding' do
      expect(HMAC::MD5).to receive_message_chain(:new, :update, :hexdigest) # receive(:hexdigest).with(source)
      subject
    end
  end

  describe '#bytesized_hash' do
    let(:hash) do
      {
        amount: '1234',
        testorder: 'FALSE'
      }
    end
    let(:value) { '41234' }

    subject { service.send(:bytesized_hash) }

    before do
      service.instance_variable_set(:@hash, hash)
    end

    it { is_expected.to eq value }
  end
end
