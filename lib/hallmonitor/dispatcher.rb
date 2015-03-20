module Hallmonitor
  class Dispatcher
    @outputters = []

    # Returns list of outputters registered
    # @return [Array<Outputter>]
    def self.outputters
      @outputters
    end

    # Adds an outputter.  Outputters are required to respond to :process
    # @param outputter [Object]
    # @see Hallmonitor::Outputters::StatsdOutputter
    def self.add_outputter(outputter)
      @outputters << outputter if outputter.respond_to?(:process)
    end

    # Removes all outputters
    def self.clear_outputters
      @outputters = []
    end

    # Outputs the event via each registered outputter
    # @param event [Event] The event to output
    def self.output(event)
      @outputters.each do |o|
        begin
          o.process(event)
        rescue
          raise unless Hallmonitor.config.trap_outputter_exceptions
        end
      end
    end
  end
end
