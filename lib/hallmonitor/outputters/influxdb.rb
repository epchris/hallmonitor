begin
  require 'influxdb'
rescue LoadError
end

module Hallmonitor
  module Outputters
    # An outputter for StatsD
    class InfluxdbOutputter < Outputter
      # Builds a new InfluxdbOutputter
      # @param influxdb_client [InfluxDB::Client] client instance to use
      # @param tags [Hash] Set of default tags applied to all events output to
      #   InfluxDB, will be overridden by tags set by events if they conflict
      # @raise if Statsd is undefined (Gem not present)
      def initialize(influxdb_client, tags)
        raise "In order to use InfluxdbOutputter, influxdb gem must be installed" unless defined?(InfluxDB)
        super("influxdb")
        @tags = tags
        @client = influxdb_client
      end

      # Sends events to statsd instance
      def process(event)
        tags = @tags.merge(event.tags)

        data = {}

        if(event.respond_to?(:duration))
          tags = {type: 'timer'}.merge(tags)
          data = {
            values: {value: event.duration},
            tags: tags
          }
          @client.write_point(event.name, data)
        elsif(event.respond_to?(:value))
          tags = {type: 'guage'}.merge(tags)
          data = {
            values: {value: event.value},
            tags: tags
          }
        else
          tags = {type: 'count'}.merge(tags)
          data = {
            values: {value: event.count},
            tags: tags
          }
        end

        @client.write_point(event.name, data)
      end

    end
  end
end
