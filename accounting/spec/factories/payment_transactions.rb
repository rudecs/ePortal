FactoryBot.define do
  factory :payment_transaction do
    amount   { Faker::Number.decimal(2, 4) }
    currency 'rub'
    subject  { create(:paid_writeoff) }
    client   { create(:prepaid) }
  end
end
