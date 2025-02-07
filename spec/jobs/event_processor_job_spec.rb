require 'rails_helper'

RSpec.describe EventProcessorJob, type: :job do
  subject(:process_event) { described_class.perform_now(event.external_id) }

  describe '#perform' do
    context 'when the event is customer.subscription.created' do
      let(:event) { create(:event, :subscription_created) }

      it 'enqueues ProcessCustomerSubscriptionCreatedJob with the correct external_id' do
        expect(ProcessCustomerSubscriptionCreatedJob).to receive(:perform_later).with(event.external_id)
        process_event
      end
    end

    context 'when the event is invoice.paid' do
      let(:event) { create(:event, :invoice_paid) }

      it 'enqueues ProcessInvoicePaidJob with the correct external_id' do
        expect(ProcessInvoicePaidJob).to receive(:perform_later).with(event.external_id)
        process_event
      end
    end

    context 'when the event is customer.subscription.deleted' do
      let(:event) { create(:event, :subscription_deleted) }

      it 'enqueues ProcessCustomerSubscriptionDeletedJob with the correct external_id' do
        expect(ProcessCustomerSubscriptionDeletedJob).to receive(:perform_later).with(event.external_id)
        process_event
      end
    end
  end
end
