# app/handlers/pinpoint/application_hired_handler.rb

module Pinpoint
  class ApplicationHiredHandler < BaseEventHandler
    def call
      application_id = @event.payload.dig('data', 'application', 'id')
      application = fetch_application(id: application_id)

      create_employee(application)
    end

    private

    def application_fetcher
      Apis::Pinpoint::Applications::Fetch.new
    end

    def create_employee(application)
      employee_creator.call(
        first_name: application['data']['attributes']['first_name'],
        surname: application['data']['attributes']['last_name'],
        email: application['data']['attributes']['email'],
        site: 'New York (Demo)',
        start_date: 2.weeks.from_now
      )
    end

    def employee_creator
      Apis::HiBob::People::Create.new
    end

    def fetch_application(id:)
      application_fetcher.call(id:)
    end
  end
end
