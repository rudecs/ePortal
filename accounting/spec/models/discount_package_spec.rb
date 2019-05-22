require 'rails_helper'

RSpec.describe DiscountPackage, type: :model do
  let(:discount_package) { create(:discount_package) }

  describe 'validations' do
    it { expect(discount_package).to be_valid }
  end
end
