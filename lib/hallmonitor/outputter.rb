module Hallmonitor
  class Outputter
    attr_reader :name
    @@outputters = Array.new

    def initialize(name)
      raise(ArgumentError, "Outputter expects a name") if name.nil?
      @name = name
    end

    # Returns the current list of outputters
    # @return [Object] Outputters
    def self.outputters
      @@outputters
    end

    # Adds an outputter.  Outputters are required to respond to :process
    # @see Hallmonitor::Outputters::StatsdOutputter
    def self.add_outputter(outputter)
      @@outputters << outputter if outputter.respond_to?(:process)
    end

    # Outputs the event via each configured outputter
    # @param event [Event] The event to output
    def self.output(event)
      @@outputters.each do |o|
        o.process(event)
      end
    end

    # Processes and event.  Child classes should implement this to output events
    # @param event [Event] the event to process
    def process(event)
      # Nothing
    end
  end
end
