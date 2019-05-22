require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:client) do
    FactoryBot.build(:client)
  end

  it { expect(client).to be_valid }

  describe 'associations' do
    it { expect(client).to have_many(:roles).inverse_of(:client).dependent(:destroy) }
  end

  describe 'validations' do
    it { expect(client).to validate_presence_of(:name) }
    it { expect(client).to validate_presence_of(:state) }
    it { expect(client).to validate_inclusion_of(:state).in_array(%w(active)) }
  end

  describe 'callbacks' do
  end

  describe 'scopes' do
  end

  describe 'public instance methods' do
    context 'responds to its methods' do
      # it { expect().to respond_to(:) }
    end

    context 'executes methods correctly' do
    end
  end

  describe 'class methods' do
  end
end
