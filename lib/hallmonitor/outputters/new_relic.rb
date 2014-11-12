module Hallmonitor
  module Outputters
    # Outputs events to NewRelic using their custom metrics API
    class NewRelic < Outputter
      # Initializes a new instance
      # @raise String if {NewRelic::Agent} isn't defined (Library isn't loaded)
      # @param prefix [String] String to prefix all metrics with
      def initialize(prefix='')
        raise "In order to use NewRelic, new_relic gem must be installed" unless defined?(::NewRelic::Agent)
        super(prefix)
      end

      def process(event)
        if(event.respond_to?(:duration))
          ::NewRelic::Agent.record_metric(new_relic_name(event), event.duration)
        elsif(event.respond_to?(:value))
          ::NewRelic::Agent.record_metric(new_relic_name(event), event.value)
        else
          ::NewRelic::Agent.increment_metric(new_relic_name(event), event.count)
        end
      end

      private
      # Formats the event name into the naming scheme that NewRelic expects
      def new_relic_name(event)
        "Custom/#{event.name.gsub('.','/')}"
      end
    end
  end
end
