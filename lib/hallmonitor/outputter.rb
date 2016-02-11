module Hallmonitor
  # An {Outputter} is an object that can process {Hallmonitor::Event}s
  class Outputter
    attr_reader :name

    # Initializes a new Outputter
    # @param name [Object] Probably a string or symbol, the name of this
    # outputter
    def initialize(name)
      fail(ArgumentError, 'Outputter expects a name') if name.nil?
      @name = name
    end

    # Processes an event.  Child classes should implement this to output events
    # @param event [Event] the event to process
    def process(event)
      # Nothing
    end
  end
end
