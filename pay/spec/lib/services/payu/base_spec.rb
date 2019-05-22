# frozen_string_literal: true

require 'rails_helper'

describe Services::Payu::Base do
  let(:amount)    { 20_000 }
  let(:decorator) { double(:decorator, formatted_amount: amount, currency: 'RUB') }
  let(:payment)   { double(:payment, id: 555, decorate: decorator, created_at: Time.current) }
  let(:service)   { described_class.new(payment) }

  describe '#signature' do
    let(:source) { double(:source) }
    subject { service.signature }

    before do
      allow(service).to receive(:signature_source).and_return source
    end

    it 'should use signature service for encoding' do
      expect(Services::Payu::Signature).to receive_message_chain(:new, :call) # receive(:hexdigest).with(source)
      subject
    end
  end

  describe '#signature_source' do
    let(:merchant) { 'de_portal_merchant' }
    let(:desc) { 'desc' }
    let(:value) do
      {
        merchant: merchant,
        order_ref: payment.id.to_s,
        order_date: payment.created_at.strftime('%F %T'),
        order_pname: desc,
        order_pcode: [payment.id.to_s],
        order_price: [payment.decorate.formatted_amount],
        order_qty: ['1'],
        order_vat: ['0'],
        prices_currency: payment.decorate.currency,
        # testorder: (!Rails.env.production?).to_s.upcase
        testorder: 'TRUE'
      }
    end

    subject { service.signature_source } # subject { service.send :signature_source }

    before do
      allow(Rails).to receive_message_chain(:application, :secrets, :payu, :dig).and_return merchant
      allow(CONFIG).to receive_message_chain(:payu, :desc).and_return desc
    end

    it { is_expected.to eq value }
  end
end
