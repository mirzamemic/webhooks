class EventProcessorJob < ApplicationJob
  queue_as :default

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

  def perform(event_id)
    event = Event.find_by(external_id: event_id)

    return unless event.pending? && ALLOWED_EVENTS.include?(event.name)

    case event.name
    when "customer.subscription.created"
      ProcessCustomerSubscriptionCreatedJob.perform_later(event.external_id)
    when "customer.subscription.deleted"
      ProcessCustomerSubscriptionDeletedJob.perform_later(event.external_id)
    when "customer.subscription.updated"
      # TODO: Sync subscription changes
      # ProcessCustomerSubscriptionUpdatedJob.perform_later(event.external_id)
    when "invoice.paid"
      ProcessInvoicePaidJob.perform_later(event.external_id)
    when "invoice.payment_failed"
      # TODO: Mark subscription as past_due
      # ProcessInvoicePaymentFailedJob.perform_later(event.external_id)
    when "payment_intent.succeeded"
      # TODO: Handle successful one-time payment
      # ProcessPaymentIntentSucceededJob.perform_later(event.external_id)
    when "payment_intent.payment_failed"
      # TODO: Handle failed one-time payment
      # ProcessPaymentIntentFailedJob.perform_later(event.external_id)
    else
      Rails.logger.warn "⚠️ No job assigned for event: #{event.name}"
    end
  end
end
