# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'

require_relative '../../../../../app/lib/apis/pinpoint/applications/add_comment'

RSpec.describe Apis::Pinpoint::Applications::AddComment do
  let(:base_url) { 'http://api.example.com' }
  let(:api_key) { 'test_api_key' }
  let(:application_id) { '12345' }
  let(:comment) { 'This is a test comment.' }
  let(:default_headers) do
    {
      'x-api-key' => api_key,
      'content-type' => 'application/json'
    }
  end
  let(:body) do
    {
      data: {
        attributes: {
          body_text: comment
        },
        relationships: {
          commentable: {
            data: {
              type: 'applications',
              id: application_id.to_s
            }
          }
        },
        type: 'comments'
      }
    }
  end

  before do
    stub_const("#{Apis::Pinpoint::Base}::BASE_URL", base_url)
    stub_const("#{Apis::Pinpoint::Base}::API_KEY", api_key)
  end

  describe '#call' do
    let(:path) { '/api/v1/comments' }
    let(:full_url) { "#{base_url}#{path}" }

    context 'when the request is successful' do
      it 'makes a POST request and handles a successful response' do
        stub_request(:post, full_url)
          .with(
            headers: default_headers,
            body: body.to_json
          )
          .to_return(status: 201, body: '{"status":"success"}', headers: {})

        commenter = described_class.new
        response = commenter.call(id: application_id, comment:)

        expect(response).to eq('status' => 'success')
      end
    end

    context 'when the request fails' do
      it 'raises an error on failed request' do
        stub_request(:post, full_url)
          .with(
            headers: default_headers,
            body: body.to_json
          )
          .to_return(status: 400, body: '{"error":"Bad Request"}')

        commenter = described_class.new

        expect do
          commenter.call(id: application_id, comment:)
        end.to raise_error(Apis::Pinpoint::BadRequestError)
      end
    end
  end
end
