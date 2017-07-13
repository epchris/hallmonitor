begin
  require 'datadog/statsd'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for Dogstatsd
    class DogstatsdOutputter < Outputter
      # Builds a new DogstatsdOutputter.
      # @param prefix [String] Prefix for all events output by this outputter,
      #   the prefix will be applied to all event names before sending to statsd
      # @param host [String] Datadog Host, defaults to '127.0.0.1'
      # @param port [Number] Datadog Port, defaults to 8125
      # @raise if Datadog::Statsd is undefined (Gem not present)
      def initialize(prefix, host = '127.0.0.1', port = 8125, tags: {})
        unless defined?(Datadog::Statsd)
          fail 'In order to use DogstatsdOutputter, dogstatsd-ruby gem must be installed'
        end

        super(prefix)
        @tags = {}.merge(tags)
        @statsd = Datadog::Statsd.new(host).tap { |sd| sd.namespace = name }
      end

      # Sends events to statsd instance
      # If the event's value field is a hash, this will send multiple events
      # to statsd with the original name suffixed by the name of the events
      # in the hash

      def process_tags(tags)
        @tags = @tags.merge(tags)
        tags_array = Array.new
        for k,v in @tags
          tags_array.push("#{k}:#{v}")
        end
        return tags_array
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
        event_name = name_for(event)
        if event.duration.is_a?(Hash)
          event.duration.each do |name, value|
            @statsd.timing("#{event_name}.#{name}", value, :tags => process_tags(event.tags))
          end
        else
          @statsd.timing(event_name, event.duration)
        end
      end

      def process_gauge_event(event)
        event_name = name_for(event)
        if event.value.is_a?(Hash)
          event.value.each do |name, value|
            @statsd.gauge("#{event_name}.#{name}", value, :tags => process_tags(event.tags))
          end
        else
          @statsd.gauge(event_name, event.value, :tags => process_tags(event.tags))
        end
      end

      def process_event(event)
        event_name = name_for(event)
        if event.count.is_a?(Hash)
          event.count.each do |name, value|
            @statsd.count("#{event_name}.#{name}", value, :tags => process_tags(event.tags))
          end
        else
          @statsd.count(event_name, event.count, :tags => process_tags(event.tags))
        end
      end

      def name_for(event)
        event.name
      end
    end
  end
end
