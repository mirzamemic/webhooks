class Subscription < ApplicationRecord
  INCOMPLETE = "incomplete"
  INCOMPLETE_EXPIRED = "incomplete_expired"
  TRIALING = "trialing"
  ACTIVE = "active"
  PAST_DUE = "past_due"
  CANCELED = "canceled"
  UNPAID = "unpaid"
  PAUSED = "paused"

  enum :status, {
    incomplete: INCOMPLETE,                  # Initial payment failed or requires user action
    incomplete_expired: INCOMPLETE_EXPIRED,  # Subscription expired due to non-payment
    trialing: TRIALING,                      # In trial period before first payment
    active: ACTIVE,                          # Subscription is fully active
    past_due: PAST_DUE,                      # Payment failed but still within retry attempts
    canceled: CANCELED,                      # Subscription has been canceled
    unpaid: UNPAID,                          # Subscription is unpaid, but still exists
    paused: PAUSED                           # Subscription has been temporarily paused
  }

  belongs_to :customer

  validates :external_id, presence: true, uniqueness: true
  validates :status, presence: true
end
