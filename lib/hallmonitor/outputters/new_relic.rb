module Hallmonitor
  module Outputters
    # Outputs events to NewRelic using their custom metrics API
    class NewRelic < Outputter
      # Initializes a new instance
      # @raise String if {NewRelic::Agent} isn't defined (Library isn't loaded)
      # @param prefix [String] String to prefix all metrics with
      def initialize(prefix = '')
        unless defined?(::NewRelic::Agent)
          fail 'In order to use NewRelic, new_relic gem must be installed'
        end
        super(prefix)
      end

      def process(event)
        if event.is_a?(Hallmonitor::TimedEvent)
          process_timed_event(event)
        elsif event.is_a?(Hallmonitor::GaugeEvent)
          process_gauge_event(event)
        else
          process_event(event)
        end
      end

      private

      def process_timed_event(event)
        if event.duration.is_a?(Hash)
          event.duration.each do |name, value|
            ::NewRelic::Agent.record_metric(new_relic_name("#{event.name}.#{name}"), value)
          end
        else
          ::NewRelic::Agent.record_metric(new_relic_name(event.name), event.duration)
        end
      end

      def process_gauge_event(event)
        if event.value.is_a?(Hash)
          event.value.each do |name, value|
            ::NewRelic::Agent.record_metric(new_relic_name("#{event.name}.#{name}"), value)
          end
        else
          ::NewRelic::Agent.record_metric(new_relic_name(event.name), event.value)
        end
      end

      def process_event(event)
        if event.count.is_a?(Hash)
          event.count.each do |name, value|
            ::NewRelic::Agent.increment_metric(new_relic_name("#{event.name}.#{name}"), value)
          end
        else
          ::NewRelic::Agent.increment_metric(new_relic_name(event.name), event.count)
        end
      end

      # Formats the event name into the naming scheme that NewRelic expects
      def new_relic_name(name)
        "Custom/#{name.tr('.', '/')}"
      end
    end
  end
end
