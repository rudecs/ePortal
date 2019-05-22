# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    name                    { Faker::Name.name }
    state                   'active'
    deleted_at              nil
    current_balance_cents   0
    currency                'rub'
    discount_package_id     nil
    next_billing_end_date   nil
    next_billing_start_date nil

    factory :prepaid do
      writeoff_type 'prepaid'
    end

    factory :postpaid do
      writeoff_type     'postpaid'
      writeoff_interval 3
      writeoff_date     nil
    end

    trait :deleted do
      deleted_at Time.zone.now
    end
  end
end
