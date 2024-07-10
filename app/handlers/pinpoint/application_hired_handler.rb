# app/handlers/pinpoint/application_hired_handler.rb

module Pinpoint
  class ApplicationHiredHandler < BaseEventHandler
    def call
      application_id = @event.payload.dig('data', 'application', 'id')
      application = fetch_application(id: application_id)

      employee = create_employee(application)
      employee_id = employee['id']

      cv_url = cv_url(application)
      add_cv_to_employee(employee_id, 'CV', cv_url) if cv_url

      add_comment_to_application(application_id, employee_id)
    end

    private

    def add_comment_to_application(id, employee_id)
      comment_creator = Apis::Pinpoint::Applications::AddComment.new
      comment_creator.call(id:, comment: "Record created with ID: #{employee_id}")
    end

    def add_cv_to_employee(person_id, document_name, document_url)
      public_document_creator = Apis::HiBob::People::AddSharedDocument.new
      public_document_creator.call(person_id:, document_name:, document_url:)
    end

    def create_employee(application)
      employee_creator = Apis::HiBob::People::Create.new
      employee_creator.call(
        first_name: application['data']['attributes']['first_name'],
        surname: application['data']['attributes']['last_name'],
        email: application['data']['attributes']['email'],
        site: 'New York (Demo)',
        start_date: 2.weeks.from_now
      )
    end

    def cv_url(application)
      application.dig('data', 'attributes', 'attachments')
                 &.find { |attachment| attachment['context'] == 'pdf_cv' }
                 &.dig('url')
    end

    def fetch_application(id:)
      application_fetcher = Apis::Pinpoint::Applications::Fetch.new
      application_fetcher.call(id:, options: { extra_fields: %w[attachments] })
    end
  end
end
