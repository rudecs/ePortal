FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { Faker::Base.numerify('7916#######') }
    password { '123123' }
    state { 'active' }
  end
end
