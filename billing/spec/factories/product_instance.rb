FactoryBot.define do
  factory :product_instance do
    after(:create) do |product_instance, evaluator|
      billing_code_version = create(:billing_code_version, product_instance: product_instance)
      product_instance.current_billing_code_version_id = billing_code_version.id
    end
  end
end
