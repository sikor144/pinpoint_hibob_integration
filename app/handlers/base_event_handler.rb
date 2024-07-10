# frozen_string_literal: true

class BaseEventHandler
  def initialize(event)
    @event = event
  end

  def call
    raise NotImplementedError, 'Subclasses must implement a `call` method'
  end
end
