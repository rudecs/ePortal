FactoryBot.define do
  factory :profile do
    association :role
    association :user
  end
end
