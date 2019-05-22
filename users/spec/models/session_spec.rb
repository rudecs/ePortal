require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:session) do
    FactoryBot.build(:session)
  end

  it { expect(session).to be_valid }

  describe 'associations' do
    it { expect(session).to belong_to(:user).inverse_of(:sessions) }
  end

  describe 'validations' do
  it { expect(session).to validate_presence_of(:user) }
  end

  describe 'callbacks' do
    it { expect(session.expired_at).to be_nil }
    it { session.save! ; expect(session.expired_at.to_date).to eq((Time.now + 14.days).to_date) }

    it { expect(session.token).to be_nil }
    it { session.save! ; expect(session.token).to be_present }
    it { session.save! ; expect(session.token.class).to eq(String) }
  end

  describe 'scopes' do
  end

  describe 'public instance methods' do
    context 'responds to its methods' do
      it { expect(session).to respond_to(:token?) }
      it { expect(session).to respond_to(:regenerate_token) }
    end

    context 'executes methods correctly' do
    end
  end

  describe 'class methods' do
  end
end
