require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  let(:payment_transaction) { create(:payment_transaction) }

  describe 'validations' do
    it { expect(payment_transaction).to be_valid }
  end
end
