# frozen_string_literal: true

require_relative '../base'

module Apis
  module HiBob
    module People
      # `Fetch` class is responsible for fetching an employee.
      class Fetch < Base
        def call(id:)
          post('v1/people/identifier', { identifier: id })
        end
      end
    end
  end
end
