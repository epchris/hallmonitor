begin
  require 'influxdb'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for InfluxDB
    class InfluxdbOutputter < Outputter
      # Builds a new InfluxdbOutputter
      # @param influxdb_client [InfluxDB::Client] client instance to use
      # @param tags [Hash] Set of default tags applied to all events output to
      #   InfluxDB, will be overridden by tags set by events if they conflict
      # @param transformer [#transform(String)] An object that responds
      #   to #transform(String).  If supplied it will be passed each event name
      #   and should return a hash with keys :name and :tags.  This is to allow
      #   for transition from a statsd/graphite style event naming convention to
      #   an InfluxDb style name+tags convention.  Any tags returned by the
      #   transformer will defer to tags specified in the event itself, in
      #   other words if the event has tags already they will take precedence
      #   over tags built by the transformer
      # @raise if influxdb_client does not respond to :write_point
      #   (InfluxDB::Client contract)
      def initialize(influxdb_client, tags = {}, transformer = nil)
        unless influxdb_client.respond_to?(:write_point)
          fail 'Supplied InfluxDB Client was not as expected'
        end

        if transformer && !transformer.respond_to?(:transform)
          fail 'Supplied transformer does not respond to :transform'
        end

        super('influxdb')
        @tags = {}.merge(tags)
        @client = influxdb_client || fail('Must supply an InfluxDb client')
        @transformer = transformer
      end

      # Sends events to InfluxDB instance
      # @param evvent []
      def process(event)
        data =
          if event.respond_to?(:duration)
            build_timer_data(event)
          elsif event.respond_to?(:value)
            build_gauge_data(event)
          else
            build_counter_data(event)
          end
        transform_and_write(event, data)
      end

      private

      def transform_and_write(event, data)
        to_write = transform(event, data)
        @client.write_point(to_write[:name], to_write[:data])
      end

      # If @transformer exists, use it to transform the event name
      # and possibly build tags from it.
      # @param event [Event] The event we're working with
      # @param data [Hash] Hash of data we're building for InfluxDB,
      #   Will be modified directly if the transformer is specified.
      # @see {#build_data} for information on the structure of `data`
      def transform(event, data)
        if @transformer
          t = @transformer.transform(event.name)
          data[:tags] = (t[:tags] || {}).merge(data[:tags])
          { name: t[:name], data: data }
        else
          { name: event.name, data: data }
        end
      end

      def build_data(event, type, value)
        {
          tags: @tags.merge(event.tags.merge(type: type)),
          values: { value: value }
        }
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
