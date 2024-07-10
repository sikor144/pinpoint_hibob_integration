# frozen_string_literal: true

class WebhookEvent < ApplicationRecord
  validates :source, :event_name, :payload, :status, presence: true
  validates :event_signature, uniqueness: true

  enum status: { created: 'created', processing: 'processing', failed: 'failed', success: 'success' }
end
