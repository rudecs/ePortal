FactoryBot.define do
  factory :client do
    name { Faker::Lorem.characters(20) }
    state { 'active' }
  end

  # factory :deleted_client do
  #   name { Faker::Lorem.characters(20) }
  #   state { 'deleted' }
  #   deleted_at "2018-04-26 10:52:30"
  # end
end
