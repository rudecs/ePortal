# frozen_string_literal: true

FactoryBot.define do
  factory :resource do
    resource_id         { Faker::Number.unique.between(1, 100) } # SecureRandom.random_number(100)
    product_id          { Faker::Number.between(1, 10) }
    client_id           { Faker::Number.between(1, 10) }
    partner_id          { Faker::Number.between(1, 10) }
    deleted_at          nil
    product_instance_id { Faker::Number.between(1, 10) } # TODO: proper validations

    factory :cloud_space_resource do
      kind 'CloudSpace'
    end

    factory :machine_resource do
      kind 'Machine'
    end

    trait :deleted do
      deleted_at Time.zone.now
    end
  end
end
