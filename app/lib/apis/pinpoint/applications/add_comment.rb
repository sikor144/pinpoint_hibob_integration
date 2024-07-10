# frozen_string_literal: true

require_relative '../base'

module Apis
  module Pinpoint
    module Applications
      # `AddComment` class is responsible for adding a comment to an application.
      # It requires an application ID and a comment.
      class AddComment < Base
        def call(id:, comment:)
          body = build_body(id, comment)
          post('/api/v1/comments', body)
        end

        private

        def build_body(application_id, comment)
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
      end
    end
  end
end
