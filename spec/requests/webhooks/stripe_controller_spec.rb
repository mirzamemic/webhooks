require 'rails_helper'
require 'ostruct'

RSpec.describe Webhooks::StripeController, type: :request do
  subject(:send_webhook) { post webhooks_stripe_path, params: event_payload.to_json, headers: headers }

  let(:event_id) { "evt_#{SecureRandom.hex(8)}" }
  let(:event_type) { "customer.subscription.created" }
  let(:stripe_event_mock) { OpenStruct.new(id: event_id, type: event_type, to_h: event_payload) }

  let(:event_payload) do
    {
      "id" => event_id,
      "type" => event_type,
      "data" => { "object" => { "id" => "sub_123", "customer" => "cus_123" } }
    }
  end

  let(:headers) do
    {
      "CONTENT_TYPE" => "application/json",
      "HTTP_STRIPE_SIGNATURE" => "valid_signature"
    }
  end

  before do
    allow(Stripe::Webhook).to receive(:construct_event).and_return(stripe_event_mock)
    allow(EventProcessorJob).to receive(:perform_later)
  end

  describe "POST /webhooks/stripe" do
    context "when the signature is valid" do
      it "creates an event and enqueues the job" do
        expect { send_webhook }.to change(Event, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(EventProcessorJob).to have_received(:perform_later).with(event_id)
      end
    end

    context "when the signature is invalid" do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(Stripe::SignatureVerificationError.new("Invalid signature", "sig_header"))
      end

      it "returns 400 Bad Request and does not create an event" do
        expect { send_webhook }.not_to change(Event, :count)
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include("Invalid signature")
      end
    end
  end
end
