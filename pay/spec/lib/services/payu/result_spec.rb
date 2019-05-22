# frozen_string_literal: true

require 'rails_helper'

describe Services::Payu::Result do
  let!(:payment)  { create(:payment) }
  let(:out_sum)   { payment.amount }
  let(:signature) { 'MD5 signature' }
  let(:method)    { 'Visa/MasterCard/Eurocard' }
  let(:order_st)  { 'ORDERSTATUS' }
  let(:params) do
    {
      REFNOEXT: payment.id, # int, string donno
      IPN_TOTALGENERAL: out_sum, # TODO: change IPN_TOTALGENERAL to right key
      CURRENCY: payment.currency,
      HASH: signature,
      PAYMETHOD: method,
      ORDERSTATUS: order_st
      # + ipn_signature_source uses @params[:IPN_PID][0] @params[:IPN_PNAME][0] @params[:IPN_DATE]
    }
  end
  let(:service) { described_class.new(params) }

  describe '#valid?' do
    subject { service.valid? }
    before do
      allow(service).to receive(:result_signature).and_return calculated_signature
      service.instance_variable_set(:@payment, payment)
      allow(payment).to receive(:currency).and_return currency
    end

    context 'when valid signature' do
      let(:calculated_signature) { signature }
      let(:currency) { payment.currency }
      it { is_expected.to be_truthy }
    end

    context 'when invalid signature' do
      let(:calculated_signature) { 'wrong signature' }
      let(:currency) { payment.currency }
      it { is_expected.to be_falsey }
    end

    context 'when matching currency' do
      let(:calculated_signature) { signature }
      let(:currency) { payment.currency }
      it { is_expected.to be_truthy }
    end

    context 'when not matching currency' do
      let(:calculated_signature) { signature }
      let(:currency) { 'wrong currency' }
      it { is_expected.to be_falsey }
    end
  end

  describe '#check_external_status' do
    subject { service.check_external_status }
  end

  describe '#verify_payment' do
    subject { service.verify_payment }
    after { subject }
    it { expect(service).to receive(:save_status) }
    it { expect(service).to receive(:save_payment_method) }
    it { expect(service).to receive(:check_amount) }
  end

  describe '#save_status' do
    subject { service.send(:save_status) }
    before { service.instance_variable_set(:@payment, payment) }
    after { subject }

    it 'should update payment' do
      expect(payment).to receive(:update_column).with(:status, order_st)
    end
  end

  describe '#save_payment_method' do
    subject { service.send(:save_payment_method) }
    before { service.instance_variable_set(:@payment, payment) }
    after { subject }
    it 'should update payment' do
      expect(payment).to receive(:update_column).with(:payment_method, method)
    end
  end

  describe '#check_amount' do
    subject { service.send(:check_amount) }
    before { service.instance_variable_set(:@payment, payment) }
    after { subject }

    context 'with the same amount' do
      it 'should not update payment' do
        expect(payment).not_to receive(:update_column)
      end
    end

    context 'with different amount' do
      let(:out_sum) { payment.amount + 1_000 }
      it 'should update amount in payment' do
        expect(payment).to receive(:update_column).with(:amount_cents, out_sum * 100)
      end
    end
  end

  describe '#response' do
    let!(:current_time) { 'Time.current' }
    let(:value) { "<epayment>#{current_time}|#{signature}</epayment>" }
    let(:signature_service) { Services::Payu::Signature }
    subject { service.response }

    before do
      service.instance_variable_set(:@current_time, current_time)
      service.instance_variable_set(:@signature_service, signature_service) # Services::Payu::Signature
      allow(service).to receive(:ipn_signature_source)
      allow(signature_service).to receive_message_chain(:new, :call).and_return signature
    end
    it { is_expected.to eq value }
  end
end
