module HiBob
  class Error < StandardError
    def initialize(message = 'An error occurred in HiBob', cause = nil)
      super(message)
      @cause = cause
    end
  end
end
