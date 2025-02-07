require 'rails_helper'

RSpec.describe 'Subscriptions', type: :request do
  describe 'GET /subscriptions' do
    context 'when there are no subscriptions' do
      it 'renders the index template with a no data message' do
        get subscriptions_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('No subscriptions found.')
      end
    end

    context 'when there are subscriptions' do
      let!(:customer) { create(:customer, name: 'John Doe', email: 'john.doe@example.com') }
      let!(:subscription) { create(:subscription, customer: customer, status: 'active') }

      it 'renders the index template with a list of subscriptions' do
        get subscriptions_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Subscription ID', 'Customer ID', 'Name', 'Email', 'Status')
        expect(response.body).to include(subscription.external_id, customer.external_id, customer.name, customer.email, subscription.status)
      end
    end
  end
end
