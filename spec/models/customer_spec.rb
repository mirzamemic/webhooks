require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_id) }
  end
end
