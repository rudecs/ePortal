# frozen_string_literal: true

require 'rails_helper'

describe Services::Balance::Charge do
  let!(:client) { create(:prepaid) }
  let!(:writeoff) { create(:paid_writeoff) }
  let(:amount) { writeoff.amount }
  let(:options) do
    {
      subject: writeoff
    }
  end
  let(:service) { described_class.new(client, amount, options) }

  describe '#call' do
    let(:transaction) { double(:transaction) }
    subject { service.call }

    before do
      service.instance_variable_set(:@payment_transaction, transaction)
    end

    it 'should use transaction' do
      expect(PaymentTransaction).to receive(:transaction)
      subject
    end

    # FIX: make it work
    # it 'should use transaction for 2nd DB' do
    #   allow(PaymentTransaction).to receive(:transaction)

    #   expect(Client).to receive(:transaction)
    #   subject
    # end

    context 'when save passed' do
      before do
        allow(transaction).to receive(:save!)
      end

      it 'should return something' do
        expect(subject).not_to be_falsey
      end

      it 'should save transaction' do
        expect(transaction).to receive(:save!)
        subject
      end

      it 'should update client`s balance' do
        expect(client).to receive(:update_balance)
        subject
      end
    end

    context 'when save failed' do
      before do
        allow(transaction).to receive(:save!).and_raise ActiveRecord::RecordInvalid
      end

      it 'should return false' do
        expect(subject).to be_falsey
      end

      it 'should NOT save transaction' do
        expect(transaction).not_to receive(:save!)
      end

      it 'should NOT update client`s balance' do
        expect(client).not_to receive(:update_balance)
      end
    end
  end

  describe '#params' do
    subject { service.send :params }
    let(:value) do
      {
        client_id: client.id,
        amount: amount,
        currency: writeoff.currency,
        subject: writeoff
      }
    end
    it { is_expected.to eq value }
  end
end
