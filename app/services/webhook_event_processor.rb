class WebhookEventProcessor
  def self.process(webhook_event)
    new(webhook_event).process
  end

  def initialize(webhook_event)
    @webhook_event = webhook_event
  end

  def process
    update_event_status('processing')
    handler = find_handler

    if handler
      handle_event(handler)
    else
      handle_missing_handler
    end
  rescue StandardError => e
    handle_processing_error(e)
  end

  private

  def update_event_status(status)
    @webhook_event.update(status:)
  end

  def find_handler
    WEBHOOK_EVENT_HANDLER_REGISTRY.handler_for(@webhook_event.source, @webhook_event.event_name)
  end

  def handle_event(handler_class)
    handler = handler_class.new(@webhook_event)
    handler.call
    update_event_status('success')
  end

  def handle_missing_handler
    update_event_status('failed')
    log_error("No handler found for #{@webhook_event.source} - #{@webhook_event.event_name}")
  end

  def handle_processing_error(exception)
    update_event_status('failed')
    log_error("Failed to process webhook event: #{exception.message}")
  end

  def log_error(message)
    Rails.logger.error(message)
  end
end
