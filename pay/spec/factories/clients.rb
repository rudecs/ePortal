# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    name                    { Faker::Name.name }
    state                   'active'
    deleted_at              nil
    current_balance_cents   0
    currency                'rub'
    writeoff_type 'prepaid'

    trait :deleted do
      deleted_at Time.zone.now
    end
  end
end
