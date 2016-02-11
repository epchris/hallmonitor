require 'json'

module Hallmonitor
  module Outputters
    # Simple outputter that just prints to an output stream
    class IOOutputter < Outputter
      # Builds a new IOOutputter
      # @param name [String] Name for this outputter
      # @param out [IO] Output to write to
      def initialize(name, out)
        super(name)
        @out = out
      end

      # Sends an event to the configured output
      # on IOError the output will be closed
      def process(event)
        @out.print "EVENT: #{event.to_json}\n"
        @out.flush
      rescue IOError
        close
      end

      private

      def close
        @out.close unless @out.nil?
      end
    end
  end
end
