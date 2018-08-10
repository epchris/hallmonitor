begin
  require 'datadog/statsd'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for Dogstatsd
    class Datadog < Outputter
      # Simple EventData struct
      EventData = Struct.new(:name, :value, :tags, :type)

      # Builds a new DogstatsdOutputter.
      # @param dogstatsd [Datadog::Statsd] Dogstatd client instance to use
      # @param tags [Hash] Default tags to apply to all metrics sent to this outputter
      def initialize(dogstatsd, tags: {})
        super('dogstatsd')
        @tags = {}.merge(tags)
        @statsd = dogstatsd
      end

      # Sends events to datadog statsd instance
      #
      # If the event's value field is a hash, this will send multiple
      # events to statsd with the original name suffixed by the name
      # of the events in the hash
      def process(event)
        event_data = build_event_data(event)
        write(event_data)
      end

      private

      # :reek:FeatureEnvy
      def write(event_data)
        event_data.each do |data|
          @statsd.send(data.type, data.name, data.value, tags: data.tags)
        end
      end

      def build_event_data(event)
        case event
        when Hallmonitor::TimedEvent
          build_timed_data(event)
        when Hallmonitor::GaugeEvent
          build_gauge_data(event)
        else
          build_count_data(event)
        end
      end

      def build_timed_data(event)
        build_data(event, event.duration, :timing)
      end

      def build_gauge_data(event)
        build_data(event, event.value, :gauge)
      end

      def build_count_data(event)
        build_data(event, event.count, :count)
      end

      # :reek:FeatureEnvy
      def build_data(event, value, type)
        event_name = event.name
        tags = process_tags(event.tags)
        if value.is_a?(Hash)
          value.map do |name, value|
            EventData.new("#{event_name}.#{name}", value, tags, type)
          end
        else
          [EventData.new(event_name, value, tags, type)]
        end
      end

      def process_tags(tags)
        @tags.merge(tags).map { |key, value| "#{key}:#{value}" }
      end
    end
  end
end
