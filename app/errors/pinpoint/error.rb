module Pinpoint
  class Error < StandardError
    def initialize(message = 'An error occurred in Pinpoint', cause = nil)
      super(message)
      @cause = cause
    end
  end
end
