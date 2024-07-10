module HiBob
  class CreateEmployee
    SITE_LOCATION = 'New York (Demo)'.freeze
    START_DATE_OFFSET = 2.weeks.freeze

    def initialize
      @employee_creator = Apis::HiBob::People::Create.new
    end

    def call(application)
      @employee_creator.call(
        first_name: application.dig('data', 'attributes', 'first_name'),
        surname: application.dig('data', 'attributes', 'last_name'),
        email: application.dig('data', 'attributes', 'email'),
        site: SITE_LOCATION,
        start_date: START_DATE_OFFSET.from_now
      )
    rescue Apis::HiBob::BadRequestError => e
      raise HiBob::Error.new('Failed to create employee: invalid data', e)
    rescue StandardError => e
      raise HiBob::Error.new("Failed to create employee for application #{application['id']}: #{e.message}", e)
    end
  end
end
