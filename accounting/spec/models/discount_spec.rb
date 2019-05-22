require 'rails_helper'

RSpec.describe Discount, type: :model do
  let(:discount) { create(:discount, :cpu_discount) }

  describe 'validations' do
    it { expect(discount).to be_valid }
  end
end
