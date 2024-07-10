# frozen_string_literal: true

module Pinpoint
  class WebhookVerificationService
    def initialize(request)
      @request = request
    end

    def verified?
      return false unless hmac_header

      ActiveSupport::SecurityUtils.secure_compare(computed_hmac, hmac_header)
    end

    private

    def hmac_header
      @request.headers['PINPOINT-HMAC-SHA256']
    end

    def computed_hmac
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), signing_secret, @request.body.read)
      Base64.strict_encode64(digest)
    end

    def signing_secret
      ENV.fetch('PINPOINT_SIGNING_SECRET', '')
    end
  end
end
