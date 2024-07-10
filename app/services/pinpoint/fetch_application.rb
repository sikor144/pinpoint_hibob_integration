module Pinpoint
  class FetchApplication
    def initialize
      @application_fetcher = Apis::Pinpoint::Applications::Fetch.new
    end

    def call(id)
      @application_fetcher.call(id:, options: { extra_fields: %w[attachments] })
    rescue Apis::Pinpoint::NotFoundError
      raise Pinpoint::Error.new("Application #{id} not found")
    rescue StandardError => e
      raise Pinpoint::Error.new("Failed to fetch application #{id}: #{e.message}", e)
    end
  end
end
