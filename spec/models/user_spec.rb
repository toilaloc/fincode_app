# frozen_string_literal: true

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:display_name) }
    it { should allow_value('user@example.com').for(:email) }
  end
end
