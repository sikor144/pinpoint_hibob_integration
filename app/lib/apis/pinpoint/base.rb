# frozen_string_literal: true

require 'faraday'
require 'json'

module Apis
  module Pinpoint
    class TimeoutError < StandardError; end
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end
    class NotFoundError < StandardError; end
    class ServerError < StandardError; end
    class UnexpectedError < StandardError; end

    # `Base` class is the parent class for all Pinpoint API classes.
    class Base
      BASE_URL = ENV.fetch('PINPOINT_BASE_URL', '')

      API_KEY = ENV.fetch('PINPOINT_API_KEY', '')

      TIMEOUT = 30

      def initialize
        @connection = Faraday.new(url: BASE_URL) do |faraday|
          faraday.headers = headers
          faraday.options.timeout = TIMEOUT
          faraday.adapter Faraday.default_adapter
        end
      end

      private

      def get(path)
        response = @connection.get(path)
        handle_response(response)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed
        raise Apis::Pinpoint::TimeoutError, 'Request timed out'
      end

      def handle_response(response)
        case response.status
        when 200, 201
          JSON.parse(response.body)
        when 400
          raise Apis::Pinpoint::BadRequestError, 'Bad Request'
        when 401
          raise Apis::Pinpoint::UnauthorizedError, 'Unauthorized'
        when 404
          raise Apis::Pinpoint::NotFoundError, 'Not Found'
        when 500...600
          raise Apis::Pinpoint::ServerError, "Server Error: #{response.status}"
        else
          raise Apis::Pinpoint::UnexpectedError, 'Unexpected Error'
        end
      end

      def headers
        {
          'x-api-key' => API_KEY,
          'content-type' => 'application/json'
        }
      end

      def post(path, body = {})
        response = @connection.post(path, body.to_json)
        handle_response(response)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed
        raise Apis::Pinpoint::TimeoutError, 'Request timed out'
      end
    end
  end
end
