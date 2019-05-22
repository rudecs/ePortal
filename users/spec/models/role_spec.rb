require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:role) do
    FactoryBot.build(:role)
  end

  it { expect(role).to be_valid }

  describe 'associations' do
    it { expect(role).to belong_to(:client).inverse_of(:roles) }
    it { expect(role).to have_many(:profiles).inverse_of(:role) }
    it { expect(role).to have_many(:users).through(:profiles).inverse_of(:role) }
  end

  describe 'validations' do
    it { expect(role).to validate_presence_of(:client) }
    it { expect(role).to validate_presence_of(:name) }
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
