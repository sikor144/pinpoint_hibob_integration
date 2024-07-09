# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'

require_relative '../../../../../app/lib/apis/hi_bob/people/create'

RSpec.describe Apis::HiBob::People::Create do
  let(:base_url) { 'https://api.hibob.com' }
  let(:username) { 'test_username' }
  let(:password) { 'test_password' }
  let(:default_headers) do
    {
      'accept' => 'application/json',
      'content-type' => 'application/json'
    }
  end
  let(:first_name) { 'John' }
  let(:surname) { 'Doe' }
  let(:email) { 'john.doe@example.com' }
  let(:site) { 'New York Office' }
  let(:start_date) { '2024-07-09' }
  let(:body) do
    {
      firstName: first_name,
      surname:,
      email:,
      work: {
        site:,
        startDate: start_date
      }
    }
  end

  before do
    stub_const("#{Apis::HiBob::Base}::BASE_URL", base_url)
    stub_const("#{Apis::HiBob::Base}::BASIC_AUTH_USERNAME", username)
    stub_const("#{Apis::HiBob::Base}::BASIC_AUTH_PASSWORD", password)
  end

  describe '#call' do
    let(:path) { '/v1/people' }
    let(:full_url) { "#{base_url}#{path}" }

    it 'makes a POST request and handles a successful response' do
      stub_request(:post, full_url)
        .with(
          headers: default_headers,
          basic_auth: [username, password],
          body: body.to_json
        )
        .to_return(status: 201, body: '{"status":"success"}', headers: {})

      creator = described_class.new
      response = creator.call(first_name:, surname:, email:, site:, start_date:)

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

      creator = described_class.new

      expect do
        creator.call(first_name:, surname:, email:, site:, start_date:)
      end.to raise_error(Apis::HiBob::BadRequestError)
    end
  end
end
