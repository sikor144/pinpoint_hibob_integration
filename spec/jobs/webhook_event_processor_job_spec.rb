# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhookEventProcessorJob, type: :job do
  let(:webhook_event) { create(:webhook_event) }

  before do
    allow(WebhookEventProcessor).to receive(:process)
  end

  describe '#perform' do
    it 'calls the WebhookEventProcessor with the webhook_event' do
      described_class.perform_now(webhook_event.id)
      expect(WebhookEventProcessor).to have_received(:process).with(webhook_event)
    end
  end
end
