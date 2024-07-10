module Pinpoint
  class ApplicationHiredHandler < BaseEventHandler
    def call
      application_id = fetch_application_id
      application = fetch_application(application_id)
      employee = create_employee(application)
      employee_id = employee['id']

      if (cv_url = extract_cv_url(application))
        add_cv_to_employee(employee_id, 'CV', cv_url)
      end

      add_comment_to_application(application_id, employee_id)
    rescue Pinpoint::Error, HiBob::Error => e
      handle_custom_error(e)
    rescue StandardError => e
      handle_standard_error(e)
    end

    private

    def fetch_application_id
      @event.payload.dig('data', 'application', 'id')
    end

    def fetch_application(id)
      Pinpoint::FetchApplication.new.call(id)
    end

    def create_employee(application)
      HiBob::CreateEmployee.new.call(application)
    end

    def add_cv_to_employee(employee_id, document_name, document_url)
      HiBob::AddCvToEmployee.new.call(employee_id, document_name, document_url)
    end

    def add_comment_to_application(application_id, employee_id)
      Pinpoint::AddCommentToApplication.new.call(application_id, employee_id)
    end

    def extract_cv_url(application)
      application.dig('data', 'attributes', 'attachments')&.find do |attachment|
        attachment['context'] == 'pdf_cv'
      end&.dig('url')
    end

    def handle_custom_error(error)
      Rails.logger.error("Custom Error in ApplicationHiredHandler: #{error.message}\n#{error.cause&.backtrace&.join("\n")}")
      raise Pinpoint::WebhookEventError.new("Failed to process application hired event: #{error.message}", error)
    end

    def handle_standard_error(error)
      Rails.logger.error("Error in ApplicationHiredHandler: #{error.message}\n#{error.backtrace.join("\n")}")
      raise Pinpoint::WebhookEventError.new("Failed to process application hired event: #{error.message}", error)
    end
  end
end
