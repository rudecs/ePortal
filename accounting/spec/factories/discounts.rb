FactoryBot.define do
  factory :discount do
    trait :cpu_discount do
      key_name 'cpu'
    end

    trait :memory_discount do
      key_name 'memory'
    end
  end
end
