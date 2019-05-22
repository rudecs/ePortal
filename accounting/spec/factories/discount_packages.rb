FactoryBot.define do
  factory :discount_package do
    name { Faker::Name.unique.name }
  end
end
