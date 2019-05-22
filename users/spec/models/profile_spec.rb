require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:profile) do
    FactoryBot.build(:profile)
  end

  it { expect(profile).to be_valid }

  describe 'associations' do
    it { expect(profile).to belong_to(:role).inverse_of(:profiles) }
    it { expect(profile).to belong_to(:user).inverse_of(:profiles) }
  end

  describe 'validations' do
    it { expect(profile).to validate_presence_of(:role) }
    it { expect(profile).to validate_presence_of(:user) }
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
