# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    amount_cents { rand(5..50) * 10_000 }
    currency     'rub'
    client       { create(:client) }
    user         { create(:user) }
    # status string
    # payment_method string

    trait :paid do
      paid_at Time.zone.now
    end

    trait :charged do
      charged_at Time.zone.now
    end
  end
end
