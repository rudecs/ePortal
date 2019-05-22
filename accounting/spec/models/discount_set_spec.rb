require 'rails_helper'

RSpec.describe DiscountSet, type: :model do
  let(:discount_set) { create(:discount_set) }

  describe 'validations' do
    it { expect(discount_set).to be_valid }
  end
end
