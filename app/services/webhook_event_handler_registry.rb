# frozen_string_literal: true

# This class is responsible for registering event handlers.
class WebhookEventHandlerRegistry
  def initialize
    @handlers = {}
  end

  def register(source, event_name, handler_class)
    @handlers[source] ||= {}
    @handlers[source][event_name] = handler_class
  end

  def handler_for(source, event_name)
    @handlers.dig(source, event_name)
  end
end
