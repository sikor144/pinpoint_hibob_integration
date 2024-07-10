# frozen_string_literal: true

require 'faraday'
require 'json'

module Apis
  module HiBob
    class TimeoutError < StandardError; end
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end
    class NotFoundError < StandardError; end
    class ServerError < StandardError; end
    class UnexpectedError < StandardError; end

    # `Base` class is the parent class for all HiBob API classes.
    class Base
      BASE_URL = ENV.fetch('HIBOB_BASE_URL', '')

      BASIC_AUTH_USERNAME = ENV.fetch('HIBOB_BASIC_AUTH_USERNAME', '')
      BASIC_AUTH_PASSWORD = ENV.fetch('HIBOB_BASIC_AUTH_PASSWORD', '')

      TIMEOUT = 30

      def initialize
        @connection = Faraday.new(url: BASE_URL) do |faraday|
          faraday.request :authorization, :basic, BASIC_AUTH_USERNAME, BASIC_AUTH_PASSWORD
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
        raise Apis::HiBob::TimeoutError, 'Request timed out'
      end

      def handle_response(response)
        case response.status
        when 200, 201
          JSON.parse(response.body)
        when 400
          raise Apis::HiBob::BadRequestError, 'Bad Request'
        when 401
          raise Apis::HiBob::UnauthorizedError, 'Unauthorized'
        when 404
          raise Apis::HiBob::NotFoundError, 'Not Found'
        when 500...600
          raise Apis::HiBob::ServerError, "Server Error: #{response.status}"
        else
          raise Apis::HiBob::UnexpectedError, 'Unexpected Error'
        end
      end

      def headers
        {
          'accept' => 'application/json',
          'content-type' => 'application/json'
        }
      end

      def post(path, body = {})
        response = @connection.post(path, body.to_json)
        handle_response(response)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed
        raise Apis::HiBob::TimeoutError, 'Request timed out'
      end
    end
  end
end
