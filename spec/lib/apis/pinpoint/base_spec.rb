# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'

require_relative '../../../../app/lib/apis/pinpoint/base'

RSpec.describe Apis::Pinpoint::Base do
  let(:base_url) { 'http://api.example.com' }
  let(:api_key) { 'test_api_key' }
  let(:default_headers) do
    {
      'x-api-key' => api_key,
      'content-type' => 'application/json'
    }
  end

  before do
    stub_const("#{Apis::Pinpoint::Base}::BASE_URL", base_url)
    stub_const("#{Apis::Pinpoint::Base}::API_KEY", api_key)
  end

  describe '#initialize' do
    it 'initializes with the correct base URL and headers' do
      base = described_class.new
      connection = base.instance_variable_get(:@connection)

      expect(connection.url_prefix.to_s).to eq("#{base_url}/")
      expect(connection.headers['x-api-key']).to eq(api_key)
      expect(connection.headers['content-type']).to eq('application/json')
    end
  end

  describe '#get' do
    let(:path) { '/test' }
    let(:full_url) { "#{base_url}#{path}" }

    it 'makes a GET request and handles a successful response' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 200, body: '{"status":"success"}', headers: {})

      base = described_class.new
      response = base.send(:get, path)

      expect(response).to eq('status' => 'success')
    end

    it 'raises TimeoutError on timeout' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_timeout

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::TimeoutError)
    end

    it 'raises BadRequestError on 400' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 400, body: '{"error":"Bad Request"}')

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::BadRequestError)
    end

    it 'raises UnauthorizedError on 401' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 401, body: '{"error":"Unauthorized"}')

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::UnauthorizedError)
    end

    it 'raises NotFoundError on 404' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 404, body: '{"error":"Not Found"}')

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::NotFoundError)
    end

    it 'raises ServerError on 500' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 500, body: '{"error":"Server Error"}')

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::ServerError)
    end

    it 'raises UnexpectedError on unknown status' do
      stub_request(:get, full_url)
        .with(headers: default_headers)
        .to_return(status: 418, body: '{"error":"I\'m a teapot"}')

      base = described_class.new

      expect { base.send(:get, path) }.to raise_error(Apis::Pinpoint::UnexpectedError)
    end
  end
end
