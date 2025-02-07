require 'rails_helper'
require 'ostruct'

RSpec.describe ProcessCustomerSubscriptionCreatedJob, type: :job do
  subject(:process_subscription_created) { described_class.perform_now(event.external_id) }

  let(:customer_external_id) { "cus_#{SecureRandom.hex(8)}" }
  let(:subscription_external_id) { "sub_#{SecureRandom.hex(8)}" }
  let(:stripe_customer_mock) { OpenStruct.new(id: customer_external_id, email: "test@example.com", name: "John Doe") }

  before do
    allow(Stripe::Customer).to receive(:retrieve).with(customer_external_id).and_return(stripe_customer_mock)
  end

  describe '#perform' do
    context 'when the event has a valid customer' do
      let(:event) { create(:event, :subscription_created, payload: { 'data' => { 'object' => { 'customer' => customer_external_id, 'id' => subscription_external_id } } }) }

      it 'creates a customer and subscription' do
        expect { process_subscription_created }
          .to change(Customer, :count).by(1)
          .and change(Subscription, :count).by(1)
      end
    end

    context 'when the customer ID is missing' do
      let(:event) { create(:event, :subscription_created, payload: { 'data' => { 'object' => {} } }) }

      it 'logs an error and marks the event as failed' do
        expect(Rails.logger).to receive(:error).with(/Missing Stripe Customer ID/)
        process_subscription_created
        expect(event.reload.status).to eq('failed')
      end
    end
  end
end
