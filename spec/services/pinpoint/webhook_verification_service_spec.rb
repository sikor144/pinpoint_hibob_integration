# spec/services/pinpoint/webhook_verification_service_spec.rb

require 'rails_helper'

RSpec.describe Pinpoint::WebhookVerificationService, type: :service do
  let(:request) { instance_double('ActionDispatch::Request', headers:, body:) }
  let(:headers) { { 'PINPOINT-HMAC-SHA256' => provided_hmac } }
  let(:body) { instance_double('StringIO', read: payload) }
  let(:provided_hmac) { 'valid_hmac' }
  let(:payload) { 'test payload' }
  let(:signing_secret) { 'test_secret' }

  before do
    allow(ENV).to receive(:fetch).with('PINPOINT_SIGNING_SECRET', '').and_return(signing_secret)
  end

  subject { described_class.new(request) }

  describe '#verified?' do
    context 'when the HMAC header is present and valid' do
      let(:computed_hmac) do
        digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), signing_secret, payload)
        Base64.strict_encode64(digest)
      end
      let(:provided_hmac) { computed_hmac }

      it 'returns true' do
        expect(subject.verified?).to be true
      end
    end

    context 'when the HMAC header is present but invalid' do
      let(:provided_hmac) { 'invalid_hmac' }

      it 'returns false' do
        expect(subject.verified?).to be false
      end
    end

    context 'when the HMAC header is missing' do
      let(:headers) { {} }

      it 'returns false' do
        expect(subject.verified?).to be false
      end
    end
  end
end
