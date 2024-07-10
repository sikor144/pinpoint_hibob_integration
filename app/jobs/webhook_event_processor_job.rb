class WebhookEventProcessorJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find(webhook_event_id)
    WebhookEventProcessor.process(webhook_event)
  end
end
