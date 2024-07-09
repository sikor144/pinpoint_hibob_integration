# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'

require_relative '../../../../../app/lib/apis/pinpoint/applications/fetch'

RSpec.describe Apis::Pinpoint::Applications::Fetch do
  let(:base_url) { 'http://api.example.com' }
  let(:api_key) { 'test_api_key' }
  let(:application_id) { '12345' }
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

  describe '#call' do
    context 'without extra fields' do
      it 'fetches the application without extra fields' do
        stub_request(:get, "#{base_url}/api/v1/applications/#{application_id}")
          .with(headers: default_headers)
          .to_return(status: 200, body: '{"status":"success"}', headers: {})

        fetcher = described_class.new
        response = fetcher.call(id: application_id)

        expect(response).to eq('status' => 'success')
      end
    end

    context 'with valid extra fields' do
      it 'fetches the application with extra fields' do
        stub_request(:get, "#{base_url}/api/v1/applications/#{application_id}?extra_fields[applications]=attachments,average_rating")
          .with(headers: default_headers)
          .to_return(status: 200, body: '{"status":"success"}', headers: {})

        fetcher = described_class.new
        response = fetcher.call(id: application_id, options: { extra_fields: %w[attachments average_rating] })

        expect(response).to eq('status' => 'success')
      end
    end

    context 'with some invalid extra fields' do
      it 'fetches the application ignoring invalid extra fields' do
        stub_request(:get, "#{base_url}/api/v1/applications/#{application_id}?extra_fields[applications]=attachments")
          .with(headers: default_headers)
          .to_return(status: 200, body: '{"status":"success"}', headers: {})

        fetcher = described_class.new
        response = fetcher.call(id: application_id, options: { extra_fields: %w[attachments invalid_field] })

        expect(response).to eq('status' => 'success')
      end
    end

    context 'with only invalid extra fields' do
      it 'fetches the application without extra fields' do
        stub_request(:get, "#{base_url}/api/v1/applications/#{application_id}")
          .with(headers: default_headers)
          .to_return(status: 200, body: '{"status":"success"}', headers: {})

        fetcher = described_class.new
        response = fetcher.call(id: application_id, options: { extra_fields: ['invalid_field'] })

        expect(response).to eq('status' => 'success')
      end
    end
  end
end
