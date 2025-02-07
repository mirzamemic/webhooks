require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
