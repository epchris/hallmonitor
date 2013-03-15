begin
  require 'statsd'
rescue LoadError
end

module Hallmonitor
  module Outputters
    class StatsdOutputter < Outputter
      def initialize(prefix, host="localhost", port=8125)
        raise "In order to use StatsdOutputter, statsd gem must be installed" unless defined?(Statsd)
        super(prefix)
        @statsd = Statsd.new(host).tap{|sd| sd.namespace = name}
      end

      def process(event)
        if(event.respond_to?(:duration))
          @statsd.timing(event.name, event.duration)
        elsif(event.respond_to?(:value))
          @statsd.guage(event.name, event.value)
        else
          @statsd.count(event.name, event.count)
        end
      end

    end
  end
end
