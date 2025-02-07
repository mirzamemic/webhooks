require 'rails_helper'

RSpec.describe ProcessCustomerSubscriptionDeletedJob, type: :job do
  subject(:process_subscription_deleted) { described_class.perform_now(event.external_id) }

  describe '#perform' do
    context 'when the subscription exists and is paid' do
      let(:event) { create(:event, :subscription_deleted) }
      let!(:subscription) { create(:subscription, external_id: event.payload.dig('data', 'object', 'id'), status: 'active') }

      it 'marks the subscription as canceled' do
        expect { process_subscription_deleted }
          .to change { subscription.reload.status }
          .from('active')
          .to('canceled')
      end
    end

    context 'when the subscription does not exist' do
      let(:event) { create(:event, :subscription_deleted) }

      it 'logs a warning and leaves the event pending' do
        expect(Rails.logger).to receive(:warn).with(/Subscription not found/)
        process_subscription_deleted
        expect(event.reload.status).to eq('pending')
      end
    end

    context 'when the subscription is not paid' do
      let(:event) { create(:event, :subscription_deleted) }
      let!(:subscription) { create(:subscription, external_id: event.payload.dig('data', 'object', 'id'), status: 'unpaid') }

      it 'logs a warning and leaves the event pending' do
        expect(Rails.logger).to receive(:warn).with(/Subscription not paid/)
        process_subscription_deleted
        expect(event.reload.status).to eq('pending')
      end
    end
  end
end
