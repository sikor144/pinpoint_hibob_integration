module Pinpoint
  class AddCommentToApplication
    COMMENT_MESSAGE = 'Record created with ID:'.freeze

    def initialize
      @comment_creator = Apis::Pinpoint::Applications::AddComment.new
    end

    def call(application_id, employee_id)
      @comment_creator.call(id: application_id, comment: "#{COMMENT_MESSAGE} #{employee_id}")
    rescue Apis::Pinpoint::NotFoundError
      raise Pinpoint::Error.new("Application #{application_id} not found")
    rescue StandardError => e
      raise Pinpoint::Error.new("Failed to add comment to application #{application_id}: #{e.message}", e)
    end
  end
end
