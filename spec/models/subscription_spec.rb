require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:customer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
