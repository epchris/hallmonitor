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

    # Outputs an event via each registered outputter.
    # If {Hallmonitor::Configuration} has the option
    # `trap_outputter_exceptions` set to `true` then this method
    # will trap and squash any errors raised by the outputter.
    # @param event [Event] The event to output
    # @return nil
    def self.output(event)
      @outputters.each do |o|
        begin
          o.process(event)
        rescue
          raise unless Hallmonitor.config.trap_outputter_exceptions
        end
      end
      nil
    end
  end
end
