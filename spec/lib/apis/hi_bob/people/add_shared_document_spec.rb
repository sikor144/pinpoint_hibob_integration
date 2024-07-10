# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'

require_relative '../../../../../app/lib/apis/hi_bob/people/add_shared_document'

RSpec.describe Apis::HiBob::People::AddSharedDocument do
  let(:base_url) { 'https://api.hibob.com' }
  let(:username) { 'test_username' }
  let(:password) { 'test_password' }
  let(:default_headers) do
    {
      'accept' => 'application/json',
      'content-type' => 'application/json'
    }
  end
  let(:person_id) { 123 }
  let(:document_name) { 'John Doe CV' }
  let(:document_url) { 'http://example.com/john_doe_cv.pdf' }
  let(:body) do
    {
      documentName: document_name,
      documentUrl: document_url
    }
  end

  before do
    stub_const("#{Apis::HiBob::Base}::BASE_URL", base_url)
    stub_const("#{Apis::HiBob::Base}::BASIC_AUTH_USERNAME", username)
    stub_const("#{Apis::HiBob::Base}::BASIC_AUTH_PASSWORD", password)
  end

  describe '#call' do
    let(:path) { "/v1/docs/people/#{person_id}/shared" }
    let(:full_url) { "#{base_url}#{path}" }

    it 'makes a POST request and handles a successful response' do
      stub_request(:post, full_url)
        .with(
          headers: default_headers,
          basic_auth: [username, password],
          body: body.to_json
        )
        .to_return(status: 201, body: '{"status":"success"}', headers: {})

      uploader = described_class.new
      response = uploader.call(person_id:, document_name:, document_url:)

      expect(response).to eq('status' => 'success')
    end

    it 'raises an error on failed request' do
      stub_request(:post, full_url)
        .with(
          headers: default_headers,
          basic_auth: [username, password],
          body: body.to_json
        )
        .to_return(status: 400, body: '{"error":"Bad Request"}')

      uploader = described_class.new

      expect do
        uploader.call(person_id:, document_name:, document_url:)
      end.to raise_error(Apis::HiBob::BadRequestError)
    end
  end
end
