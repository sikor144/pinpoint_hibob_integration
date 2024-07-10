module Pinpoint
  class WebhookEventError < StandardError
    def initialize(message = 'An error occurred in Pinpoint Webhook Event', cause = nil)
      super(message)
      @cause = cause
    end
  end
end
