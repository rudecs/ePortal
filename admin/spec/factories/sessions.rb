FactoryBot.define do
  factory :session do
    user_id { 1 }
    token { "MyString" }
    expired_at { "2018-10-29 13:31:13" }
  end
end
