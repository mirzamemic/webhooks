FactoryBot.define do
  factory :subscription do
    external_id { "sub_#{SecureRandom.hex(8)}" }
    status { Subscription::ACTIVE }
    association :customer
  end
end
