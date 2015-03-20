module Hallmonitor
  class Outputter
    attr_reader :name

    def initialize(name)
      raise(ArgumentError, "Outputter expects a name") if name.nil?
      @name = name
    end

    # Processes an event.  Child classes should implement this to output events
    # @param event [Event] the event to process
    def process(event)
      # Nothing
    end
  end
end
