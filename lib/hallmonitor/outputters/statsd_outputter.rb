begin
  require 'statsd'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for StatsD
    class StatsdOutputter < Outputter
      # Builds a new StatsdOutputter.
      # @param prefix [String] Prefix for all events output by this outputter,
      #   the prefix will be applied to all event names before sending to statsd
      # @param host [String] Statsd Host, defaults to 'localhost'
      # @param port [Number] Statsd Port, defaults to 8125
      # @param transformer [#transform(event)] An object that responds
      #   to #transform(Event).  If supplied it will be passed each event
      #   and should return an event name.  This is to allow for flattening any
      #   tags present in the event into a flattened name structure.
      # @raise if Statsd is undefined (Gem not present)
      def initialize(prefix, host = 'localhost', port = 8125, transformer = nil)
        unless defined?(Statsd)
          fail 'In order to use StatsdOutputter, statsd gem must be installed'
        end

        if transformer && !transformer.respond_to?(:transform)
          fail 'Supplied transformer does not respond to :transform'
        end

        super(prefix)
        @statsd = Statsd.new(host).tap { |sd| sd.namespace = name }
        @transformer = transformer
      end

      # Sends events to statsd instance
      # If the event's value field is a hash, this will send multiple events
      # to statsd with the original name suffixed by the name of the events
      # in the hash
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
        event_name = name_for(event)
        if event.duration.is_a?(Hash)
          event.duration.each do |name, value|
            @statsd.timing("#{event_name}.#{name}", value)
          end
        else
          @statsd.timing(event_name, event.duration)
        end
      end

      def process_gauge_event(event)
        event_name = name_for(event)
        if event.value.is_a?(Hash)
          event.value.each do |name, value|
            @statsd.gauge("#{event_name}.#{name}", value)
          end
        else
          @statsd.gauge(event_name, event.value)
        end
      end

      def process_event(event)
        event_name = name_for(event)
        if event.count.is_a?(Hash)
          event.count.each do |name, value|
            @statsd.count("#{event_name}.#{name}", value)
          end
        else
          @statsd.count(event_name, event.count)
        end
      end

      def name_for(event)
        @transformer ? @transformer.transform(event) : event.name
      end
    end
  end
end
