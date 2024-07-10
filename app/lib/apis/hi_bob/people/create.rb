# frozen_string_literal: true

require_relative '../base'

module Apis
  module HiBob
    module People
      # `Create` class is responsible for creating a new employee.
      class Create < Base
        def call(first_name:, surname:, email:, site:, start_date:, **options)
          body = build_body(first_name, surname, email, site, start_date, options)
          post('/v1/people', body)
        end

        private

        def build_body(first_name, surname, email, site, start_date, options)
          {
            firstName: first_name,
            surname:,
            email:,
            work: {
              site:,
              startDate: start_date.strftime('%Y-%m-%d')
            }
          }.merge(options)
        end
      end
    end
  end
end
