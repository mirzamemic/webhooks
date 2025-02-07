class ProcessCustomerSubscriptionDeletedJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(external_id: event_id, name: "customer.subscription.deleted")

    return unless event&.pending?

    event.processing!

    begin
      subscription = find_subscription_or_retry(event)
      return if subscription.nil?
      subscription.canceled!
      event.finished!
    rescue => e
      Rails.logger.error "❌ Failed to process event (event_id: #{event_id}): #{e.message}"
      event.pending!
    end
  end

  private

  def find_subscription_or_retry(event)
    external_id = event.payload.dig("data", "object", "id")

    unless external_id
      Rails.logger.warn "⚠️ No subscription ID in customer.subscription.deleted event (event_id: #{event.external_id}). Retrying later."
      return retry!(event)
    end

    subscription = Subscription.find_by(external_id:)

    unless subscription
      Rails.logger.warn "⚠️ Subscription not found (external_id: #{external_id}). Retrying later."
      return retry!(event)
    end

    unless subscription.active?
      Rails.logger.warn "⚠️ Subscription not paid (external_id: #{external_id}). Cannot cancel yet. Retrying later."
      return retry!(event)
    end

    subscription
  end

  def retry!(event)
    event.pending!
    nil
  end
end
