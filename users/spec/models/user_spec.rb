require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    FactoryBot.build(:user)
  end

  it { expect(user).to be_valid }

  describe 'associations' do
    it { expect(user).to have_many(:profiles).inverse_of(:user).dependent(:destroy) }
    it { expect(user).to have_many(:sessions).inverse_of(:user).dependent(:destroy) }
    it { expect(user).to have_many(:roles).through(:profiles).inverse_of(:user) }
  end

  describe 'validations' do
    it { expect(user).to validate_presence_of(:state) }
    it { expect(user).to validate_inclusion_of(:state).in_array(%w(active)) }
    it { expect(user).to have_secure_password }

    context 'phone number' do
      # it { expect(user).to validate_presence_of(:phone) }
      it { user.save!; expect(user).to validate_uniqueness_of(:phone).case_insensitive }
      it { expect(user).to allow_value(Faker::Base.numerify('+7 (9##) ### - ## - ##')).for(:phone) }
      it { expect(user).to allow_value(Faker::Base.numerify('7916#######')).for(:phone) }
      it { expect(user).to allow_value(Faker::Base.numerify('7v9y1wq6t990x85yp9h1')).for(:phone) }
      it { expect(user).to_not allow_value(Faker::Base.numerify('+7 (###) ##')).for(:phone) }
    end

    context 'email' do
      it { expect(user).to validate_uniqueness_of(:email).case_insensitive }
      it { expect(user).to allow_value(nil).for(:email) }
      it { expect(user).to allow_value(Faker::Internet.safe_email).for(:email) }
      it { expect(user).to_not allow_value('qwe@').for(:email) }
      it { expect(user).to_not allow_value('qwe@qwe').for(:email) }
      it { expect(user).to_not allow_value('@qwe').for(:email) }
      it { expect(user).to_not allow_value('qwe.ru').for(:email) }
      it { expect(user).to_not allow_value('qwe@.ru').for(:email) }
      it { expect(user).to_not allow_value('@qwe.qw').for(:email) }
    end
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
