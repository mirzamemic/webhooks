require 'rails_helper'

RSpec.describe ProcessInvoicePaidJob, type: :job do
  subject(:process_invoice_paid) { described_class.perform_now(event.external_id) }

  describe '#perform' do
    context 'when the invoice is associated with a subscription' do
      let(:event) { create(:event, :invoice_paid) }
      let!(:subscription) { create(:subscription, external_id: event.payload.dig('data', 'object', 'subscription'), status: 'unpaid') }

      it 'marks the subscription as active' do
        expect { process_invoice_paid }
          .to change { subscription.reload.status }
          .from('unpaid')
          .to('active')
      end
    end

    context 'when the invoice does not have a subscription ID' do
      let(:event) { create(:event, :invoice_paid, payload: { 'data' => { 'object' => {} } }) }

      it 'logs a warning and does not process the event' do
        expect(Rails.logger).to receive(:warn).with(/No subscription ID in invoice.paid payload/)
        expect { process_invoice_paid }.not_to change(Subscription, :count)
      end
    end

    context 'when the subscription does not exist' do
      let(:event) { create(:event, :invoice_paid) }

      it 'logs a warning and leaves the event pending' do
        expect(Rails.logger).to receive(:warn).with(/Subscription not found/)
        process_invoice_paid
        expect(event.reload.status).to eq('pending')
      end
    end
  end
end
