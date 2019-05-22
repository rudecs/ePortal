# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:deleted_at) { nil }
  let(:discount_package_id) { nil }
  let(:client) { create(:prepaid, deleted_at: deleted_at) }

  describe 'validations' do
    it { expect(client).to be_valid }
  end

  describe 'scopes' do
    describe '.prepaid' do
      subject { described_class.prepaid }

      context 'when client is prepaid' do
        it { is_expected.to include client }
      end

      context 'when client is postpaid' do
        let(:client) { create(:postpaid, deleted_at: deleted_at) }
        it { is_expected.not_to include client }
      end
    end

    describe '.postpaid' do
      subject { described_class.postpaid }

      context 'when client is prepaid' do
        it { is_expected.not_to include client }
      end

      context 'when client is postpaid' do
        let(:client) { create(:postpaid, deleted_at: deleted_at) }
        it { is_expected.to include client }
      end
    end

    describe '.active' do
      subject { described_class.active }

      context 'when client is active' do
        it { is_expected.to include client }
      end

      context 'when client is deleted' do
        let(:client) { create(:prepaid, :deleted) }
        it { is_expected.not_to include client }
      end
    end
  end

  describe '#soft_deleted?' do
    subject { client.soft_deleted? }

    context 'when client is active' do
      it 'should return FALSE' do
        expect(subject).to be_falsey
      end
    end

    context 'when client is NOT active' do
      let(:deleted_at) { Time.zone.now }
      it 'should return TRUE' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#discountable?' do
    subject { client.discountable? }

    context 'when client has NO discount' do
      it 'should return FALSE' do
        expect(subject).to be_falsey
      end
    end

    context 'when client has discount' do
      # let(:discount_package_id) { nil }
      let(:client) { build(:postpaid, discount_package_id: 1) }
      it 'should return TRUE' do
        expect(subject).to be_truthy
      end
    end
  end

  # === balance methods concern ===
  describe '#current_balance' do
    subject { client.current_balance }
    it { is_expected.to eq client.current_balance_cents.to_f / 100 }
  end

  describe '#charge' do
    let(:amount) { 3_000 }
    let(:options) do
      { foo: :bar }
    end
    let(:charge_service) { double(:service) }
    subject { client.charge(amount, options) }

    before do
      allow(Services::Balance::Charge).to receive(:new).with(client, amount, options).and_return charge_service
      allow_any_instance_of(Services::Balance::Charge).to receive(:call)
    end

    it 'should pass client with params to Services::Balance::Charge' do
      expect(Services::Balance::Charge).to receive(:new).with(client, amount, options)
      expect(charge_service).to receive(:call)
      subject
    end
  end

  describe '#update_balance' do
    let(:amount) { 30_500.to_d }
    subject { client.update_balance }

    before do
      allow(client).to receive_message_chain(:payment_transactions, :sum).and_return amount
    end

    it 'should update "current_balance_cents" column of client' do
      expect(client).to receive(:update_column).with(:current_balance_cents, (amount * 100).to_i)
      subject
    end
  end
end
