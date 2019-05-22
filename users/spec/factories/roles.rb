FactoryBot.define do
  factory :role do
    association :client

    name        { Faker::Lorem.characters(20) }
    read_only   { false }
    permissions { {} }

  end
end
