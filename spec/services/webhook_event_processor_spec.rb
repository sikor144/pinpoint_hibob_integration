# spec/services/webhook_event_processor_spec.rb

require 'rails_helper'

RSpec.describe WebhookEventProcessor, type: :service do
  let(:webhook_event) { create(:webhook_event) }
  let(:handler_class) { double('HandlerClass') }
  let(:handler_instance) { double('HandlerInstance', call: true) }

  before do
    stub_const('WEBHOOK_EVENT_HANDLER_REGISTRY', double)
    allow(WEBHOOK_EVENT_HANDLER_REGISTRY).to receive(:handler_for).and_return(handler_class)
    allow(handler_class).to receive(:new).and_return(handler_instance)
    allow(webhook_event).to receive(:update)
  end

  describe '.process' do
    it 'initializes and calls the process method' do
      processor = instance_double(described_class)
      allow(described_class).to receive(:new).and_return(processor)
      allow(processor).to receive(:process)

      described_class.process(webhook_event)

      expect(described_class).to have_received(:new).with(webhook_event)
      expect(processor).to have_received(:process)
    end
  end

  describe '#process' do
    subject { described_class.new(webhook_event) }

    context 'when handler is found' do
      it 'updates the event status to processing and then success' do
        subject.process

        expect(webhook_event).to have_received(:update).with(status: 'processing').ordered
        expect(webhook_event).to have_received(:update).with(status: 'success').ordered
      end

      it 'calls the handler' do
        subject.process

        expect(handler_class).to have_received(:new).with(webhook_event)
        expect(handler_instance).to have_received(:call)
      end
    end

    context 'when handler is not found' do
      before do
        allow(WEBHOOK_EVENT_HANDLER_REGISTRY).to receive(:handler_for).and_return(nil)
      end

      it 'updates the event status to failed' do
        subject.process

        expect(webhook_event).to have_received(:update).with(status: 'processing').ordered
        expect(webhook_event).to have_received(:update).with(status: 'failed').ordered
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with("No handler found for #{webhook_event.source} - #{webhook_event.event_name}")

        subject.process
      end
    end

    context 'when an error occurs during processing' do
      let(:error_message) { 'Processing error' }

      before do
        allow(handler_instance).to receive(:call).and_raise(StandardError.new(error_message))
      end

      it 'updates the event status to failed' do
        subject.process

        expect(webhook_event).to have_received(:update).with(status: 'processing').ordered
        expect(webhook_event).to have_received(:update).with(status: 'failed').ordered
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with("Failed to process webhook event: #{error_message}")

        subject.process
      end
    end
  end
end
