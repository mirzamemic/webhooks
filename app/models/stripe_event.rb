class StripeEvent < Event
  ALLOWED_EVENTS = %w[
    checkout.session.completed
    customer.subscription.created
    customer.subscription.updated
    customer.subscription.deleted
    invoice.paid
    invoice.payment_failed
    payment_intent.succeeded
    payment_intent.payment_failed
  ].freeze
end
