# frozen_string_literal: true

require_relative '../base'

module Apis
  module HiBob
    module People
      # `AddSharedDocument` class is responsible for adding a shared document to an employee.
      class AddSharedDocument < Base
        def call(person_id:, document_name:, document_url:)
          body = build_body(document_name, document_url)
          post("/v1/docs/people/#{person_id}/shared", body)
        end

        private

        def build_body(document_name, document_url)
          {
            documentName: document_name,
            documentUrl: document_url
          }
        end
      end
    end
  end
end
