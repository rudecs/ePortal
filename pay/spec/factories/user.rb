# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name      { Faker::Name.first_name }
    last_name       { Faker::Name.last_name }
    email           { Faker::Internet.unique.email }
    phone           { Faker::PhoneNumber.cell_phone }
    state           'active'
    password_digest 'psswd'
  end
end
