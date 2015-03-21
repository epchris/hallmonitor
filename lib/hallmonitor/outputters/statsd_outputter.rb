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
      # @raise if Statsd is undefined (Gem not present)
      def initialize(prefix, host="localhost", port=8125)
        raise "In order to use StatsdOutputter, statsd gem must be installed" unless defined?(Statsd)
        super(prefix)
        @statsd = Statsd.new(host).tap{|sd| sd.namespace = name}
      end

      # Sends events to statsd instance
      def process(event)
        if(event.respond_to?(:duration))
          @statsd.timing(event.name, event.duration)
        elsif(event.respond_to?(:value))
          @statsd.gauge(event.name, event.value)
        else
          @statsd.count(event.name, event.count)
        end
      end

    end
  end
end
