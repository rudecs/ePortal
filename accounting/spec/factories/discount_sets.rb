FactoryBot.define do
  factory :discount_set do
    discount         { create(:discount, :memory_discount) }
    discount_package { create(:discount_package) }
    amount           10
    amount_type      'percent' # 'quantity'
  end
end
