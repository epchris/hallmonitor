begin
  require 'influxdb'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for InfluxDB
    class Influxdb < Outputter
      # Simple EventData struct, used to communicate with an optional Transformer
      EventData = Struct.new(:name, :tags, :fields)

      # @return [#transform(Event, EventData)] Object used to transform data
      #   before it is sent to InfluxDB
      attr_accessor :transformer

      # Builds a new Influxdb outputter
      # @param influxdb_client [InfluxDB::Client] client instance to use
      # @param tags [Hash] Set of default tags applied to all events output to
      #   InfluxDB, will be overridden by tags set by events if they conflict
      # @param transformer [#transform(Event, EventData)] An object
      #   that responds to #transform(Event, EventData).  If supplied
      #   it will be passed the {EventData} struct that has been built
      #   so far and it should return an {EventData} struct that will
      #   be written out to InfluxDB.  This allows a hook to modify data
      #   before it is written out to InfluxDB
      # @raise if influxdb_client does not respond to :write_point
      #   (InfluxDB::Client contract)
      def initialize(influxdb_client, tags: {}, transformer: nil)
        unless influxdb_client.respond_to?(:write_point)
          raise 'Supplied InfluxDB Client was not as expected'
        end

        if transformer && !transformer.respond_to?(:transform)
          raise 'Supplied transformer does not respond to :transform'
        end

        super('influxdb')
        @tags = {}.merge(tags)
        @client = influxdb_client || raise('Must supply an InfluxDb client')
        @transformer = transformer
      end

      # Sends events to InfluxDB instance
      # @param event [Hallmonitor::Event]
      def process(event)
        event_data = build_event_data(event)
        transform_and_write(event, event_data)
      end

      private

      # @param event [Event] The original event we're working with
      # @param data [EventData] Struct of data we're building for InfluxDB
      def transform_and_write(event, event_data)
        event_data = @transformer.transform(event, event_data) if @transformer
        data = { tags: event_data.tags, values: event_data.fields }
        @client.write_point(event_data.name, data)
      end

      # Builds an {EventData} from the Hallmonitor::Event
      def build_event_data(event)
        if event.is_a?(Hallmonitor::TimedEvent)
          build_timer_data(event)
        elsif event.is_a?(Hallmonitor::GaugeEvent)
          build_gauge_data(event)
        else
          build_counter_data(event)
        end
      end

      # Builds an EventData struct for the event
      def build_data(event, type, value)
        data = EventData.new
        data.name = event.name
        data.tags = @tags.merge(event.tags.merge(type: type))
        data.fields = value.is_a?(Hash) ? value : { value: value }
        data
      end

      def build_timer_data(event)
        build_data(event, 'timer', event.duration)
      end

      def build_gauge_data(event)
        build_data(event, 'gauge', event.value)
      end

      def build_counter_data(event)
        build_data(event, 'count', event.count)
      end
    end
  end
end
