# frozen_string_literal: true

require_relative '../base'

module Apis
  module Pinpoint
    module Applications
      # `Fetch` class is responsible for fetching an application by its ID.
      # It can also fetch extra fields like attachments, average rating, and tags.
      class Fetch < Base
        EXTRA_FIELDS = %w[attachments average_rating tags].freeze

        def call(id:, options: {})
          extra_fields = build_extra_fields(options[:extra_fields])
          get("/api/v1/applications/#{id}#{extra_fields}")
        end

        private

        def build_extra_fields(extra_fields)
          return '' unless extra_fields.is_a?(Array) && extra_fields.any?

          valid_fields = extra_fields & EXTRA_FIELDS
          return '' if valid_fields.empty?

          "?extra_fields[applications]=#{valid_fields.join(',')}"
        end
      end
    end
  end
end
