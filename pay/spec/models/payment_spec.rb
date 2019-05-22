# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment) { create(:payment) }

  describe 'validations' do
    it { expect(payment).to be_valid }
  end

  describe 'scopes' do
    describe '.unpaid' do
      subject { described_class.unpaid }

      context 'when payment is unpaid' do
        it { is_expected.to include payment }
      end

      context 'when payment is paid' do
        let(:payment) { create(:payment, :paid) }
        it { is_expected.not_to include payment }
      end
    end
  end

  describe '#amount' do
    subject { payment.amount }
    it { is_expected.to eq payment.amount_cents.to_f / 100 }
  end
end
