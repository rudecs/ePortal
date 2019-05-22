FactoryBot.define do
  factory :charge, class: 'Charge::Base' do
    client_id 111
    product_id 222
    product_instance_id 333
    resource_id 333
    billing_units_digest '6a9e0ea9f95b38c6358b89c25bb3fd2a'
    time_sequence_uid { SecureRandom.uuid }
    key 'cpu'
    count 10
    price 100
    currency 'rub'
    start_at 1.hours.ago.beginning_of_hour
    end_at 1.hour.ago.end_of_hour
    billing_code_version_id 111

    factory :charge_product_instance do
      type 'Charge::ProductInstance'
    end

    factory :charge_cloud_resource do
      type 'Charge::CloudResource'
    end
  end
end
