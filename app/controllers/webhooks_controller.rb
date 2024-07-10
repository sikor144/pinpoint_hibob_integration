# frozen_string_literal: true

# This controller is responsible for processing webhooks from Pinpoint.
class WebhooksController < ApplicationController
  def create
    verification_service = Pinpoint::WebhookVerificationService.new(request)

    unless verification_service.verified?
      head :unauthorized
      return
    end

    Pinpoint::WebhookEventHandler.new(params).handle_event
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    head :unprocessable_entity
  rescue StandardError => e
    head :internal_server_error
  end
end
