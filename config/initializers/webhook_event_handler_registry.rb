# frozen_string_literal: true

unless Rails.env.test?
  require Rails.root.join('app/services/webhook_event_handler_registry')
  require Rails.root.join('app/handlers/base_event_handler')
  require Rails.root.join('app/handlers/pinpoint/application_hired_handler')

  WEBHOOK_EVENT_HANDLER_REGISTRY = WebhookEventHandlerRegistry.new

  WEBHOOK_EVENT_HANDLER_REGISTRY.register('pinpoint', 'application_hired', Pinpoint::ApplicationHiredHandler)
end
