FactoryBot.define do
  factory :event do
    type { "StripeEvent" }
    external_id { "evt_#{SecureRandom.hex(8)}" }
    name { "dummy.event" }
    payload { {} }

    trait :subscription_created do
      name { "customer.subscription.created" }
      payload do
        {
          id: external_id,
          type: name,
          data: {
            object: {
              id: "sub_#{SecureRandom.hex(8)}",
              customer: "cus_#{SecureRandom.hex(8)}",
              status: "active"
            }
          }
        }
      end
    end

    trait :invoice_paid do
      name { "invoice.paid" }
      payload do
        {
          id: external_id,
          type: name,
          data: {
            object: {
              id: "in_#{SecureRandom.hex(8)}",
              subscription: "sub_#{SecureRandom.hex(8)}",
              customer: "cus_#{SecureRandom.hex(8)}",
              amount_paid: 2000,
              currency: "usd"
            }
          }
        }
      end
    end

    trait :subscription_deleted do
      name { "customer.subscription.deleted" }
      payload do
        {
          id: external_id,
          type: name,
          data: {
            object: {
              id: "sub_#{SecureRandom.hex(8)}",
              customer: "cus_#{SecureRandom.hex(8)}",
              status: "canceled"
            }
          }
        }
      end
    end
  end
end
