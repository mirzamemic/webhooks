class Customer < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true

  # ⚠️ Note: Stripe can be configured to enforce that a customer has only ONE active subscription.
  # However, for now, we allow multiple subscriptions per customer.
  has_many :subscriptions, dependent: :destroy
end
