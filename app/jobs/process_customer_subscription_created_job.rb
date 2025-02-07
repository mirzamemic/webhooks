require "stripe"

class ProcessCustomerSubscriptionCreatedJob < ApplicationJob
  class MissingStripeCustomerError < StandardError; end

  queue_as :default

  def perform(event_id)
    event = Event.find_by(
      external_id: event_id,
      name: "customer.subscription.created"
    )

    return unless event.pending?

    event.processing!

    begin
      customer = find_or_create_customer!(event)
      create_subscription!(event, customer)
      event.finished!
      Rails.logger.info "✅ Successfully processed event (event_id: #{event_id})"
    rescue MissingStripeCustomerError => e
      event.failed!
      Rails.logger.error "⚠️ Aborting event (event_id: #{event_id}) - Missing Stripe Customer ID: #{e.message}"
      # TODO: Notify the team about the missing Stripe Customer ID.
    rescue => e
      Rails.logger.error "❌ Failed to process event (event_id: #{event_id}): #{e.message}"
      event.pending!
    end
  end

  private

  def find_or_create_customer!(event)
    external_id = event.payload.dig("data", "object", "customer")

    raise MissingStripeCustomerError, "Missing Stripe Customer ID !!!" if external_id.blank?

    customer = Customer.find_by(external_id: external_id)

    return customer if customer.present?

    stripe_customer = Stripe::Customer.retrieve(external_id)

    customer = Customer.create!(
      external_id: external_id,
      email: stripe_customer.email,
      name: stripe_customer.name
    )

    customer
  end

  def create_subscription!(event, customer)
    subscription_data = event.payload.dig("data", "object")
    external_id = subscription_data["id"]

    # TODO: Consider fetching the latest subscription details from Stripe before creating/updating locally.

    customer.subscriptions.find_or_create_by!(external_id:) do |subscription|
      subscription.status = Subscription::UNPAID
    end
  end
end
