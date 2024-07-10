# spec/models/webhook_event_spec.rb

require 'rails_helper'

RSpec.describe WebhookEvent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:source) }
    it { should validate_presence_of(:event_name) }
    it { should validate_presence_of(:payload) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:event_signature) }
  end

  describe 'enums' do
    it 'defines the correct enum values for status' do
      expect(described_class.statuses).to eq({
                                               'created' => 'created',
                                               'processing' => 'processing',
                                               'failed' => 'failed',
                                               'success' => 'success'
                                             })
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      expect(build(:webhook_event)).to be_valid
    end
  end
end
