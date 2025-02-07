require "stripe"

module Webhooks
  class StripeController < ActionController::API
    STRIPE_SIGNATURE_HEADER = "HTTP_STRIPE_SIGNATURE".freeze
    STRIPE_WEBHOOK_SECRET = "STRIPE_WEBHOOK_SECRET".freeze

    before_action :verify_signature

    def create
      event = register_event!

      # TODO: Move this job outside of the webhook request to return `head :ok` immediately.
      # Currently, we enqueue the job directly, but an alternative approach is:
      # - Use a scheduled job to process events in batches at regular intervals.
      # - This ensures webhook requests remain as fast as possible without any queuing delays.
      EventProcessorJob.perform_later(event.external_id) if event

      head :ok
    end

    private

    def register_event!
      # In a case that Stripe sends the event mutiple times, we should not create a new event.
      existing_event = StripeEvent.find_by(external_id: @event["id"])
      return existing_event if existing_event.present?

      event = StripeEvent.create!(
        external_id: @event["id"],
        name: @event["type"],
        payload: @event.to_h,
        status: ::Event::PENDING
      )

      event
    end

    def verify_signature
      return render json: { error: "Empty payload" }, status: :bad_request if payload.blank?

      begin
        @event = Stripe::Webhook.construct_event(payload, signature, secret)
      rescue JSON::ParserError
        render json: { error: "Invalid payload" }, status: :bad_request and return
      rescue Stripe::SignatureVerificationError
        Rails.logger.error "⚠️  Signature verification failed"
        render json: { error: "Invalid signature" }, status: :bad_request and return
      end
    end

    def payload
      @payload ||= request.body&.read
    end

    def signature
      @signature ||= request.env[STRIPE_SIGNATURE_HEADER]
    end

    def secret
      @secret ||= ENV[STRIPE_WEBHOOK_SECRET]
    end
  end
end
