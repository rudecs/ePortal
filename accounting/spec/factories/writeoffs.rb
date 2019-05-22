# frozen_string_literal: true

FactoryBot.define do
  factory :writeoff do
    # Faker::Number.decimal(2, 3)
    amount         nil
    initial_amount nil
    currency       'rub'
    state          'pending'
    start_date     Time.zone.now.beginning_of_hour
    end_date       { start_date.end_of_hour }
    client { create(:prepaid) }

    factory :paid_writeoff do
      paid_at        Time.zone.now
      amount         500
      initial_amount 1_000
    end

    factory :unpaid_writeoff do
      paid_at nil
    end
  end
end
