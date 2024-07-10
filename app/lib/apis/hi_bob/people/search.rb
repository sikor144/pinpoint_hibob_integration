# frozen_string_literal: true

require_relative '../ba§'

module Apis
  module HiBob
    module People
      # `Search` class is responsible for searching for an employee.
      class Search < Base
        def call
          post 'v1/people/search'
        end
      end
    end
  end
end
