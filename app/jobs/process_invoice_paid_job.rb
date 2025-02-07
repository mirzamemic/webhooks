class ProcessInvoicePaidJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event =  Event.find_by(external_id: event_id, name: "invoice.paid")

    return unless event.pending?

    event.processing!

    begin
      # TODO: Currently, we only process subscription payments.
      # In the future, we should generalize this to handle other invoice-based payments (e.g., one-time purchases).
      subscription = find_subscription_or_retry(event)
      return if subscription.nil? # Exit early if we need to retry

      subscription.active!
      event.finished!
    rescue => e
      Rails.logger.error "❌ Failed to process event (event_id: #{event_id}): #{e.message}"
      event.pending!
    end
  end

  private

  def find_subscription_or_retry(event)
    external_id = event.payload.dig("data", "object", "subscription")

    unless external_id
      # TODO: invoice.paid` can apply to various payments, not just subscriptions.
      # Currently, we retry the event, but we may need a more specific handling strategy.
      Rails.logger.warn "⚠️ No subscription ID in invoice.paid payload (event_id: #{event.external_id}). Skipping."
      event.pending!
      return nil
    end

    subscription = Subscription.find_by(external_id:)

    unless subscription
      Rails.logger.warn "⚠️ Subscription not found (external_id: #{external_id}). Retrying later..."
      event.pending!
      return nil
    end

    subscription
  end
end
