FactoryBot.define do
  factory :customer do
    external_id { "cus_#{SecureRandom.hex(8)}" }
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end
