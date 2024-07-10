# frozen_string_literal: true

require 'digest'

module Pinpoint
  class WebhookEventHandler
    def initialize(params)
      @params = params
    end

    def handle_event
      event_signature = generate_event_signature(@params)
      return if WebhookEvent.exists?(event_signature:)

      webhook_event = create_webhook_event(event_signature)
      WebhookEventProcessorJob.perform_later(webhook_event.id)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create webhook event: #{e.message}")
      raise e
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      raise e
    end

    private

    def generate_event_signature(params)
      Digest::SHA256.hexdigest(params.to_unsafe_h.to_s)
    end

    def create_webhook_event(event_signature)
      WebhookEvent.create!(
        source: 'pinpoint',
        event_name: 'application_hired',
        payload: @params.to_unsafe_h,
        status: 'created',
        event_signature:
      )
    end
  end
end
