require 'json'

module Hallmonitor
  module Outputters
    class IOOutputter < Outputter

      def initialize(name, out)
        super(name)
        @out = out
      end

      def process(event)
        begin
          @out.print "EVENT: #{event.to_json}\n"
          @out.flush
        rescue IOError => e
          close
        end
      end

      private
      def close
        @out.close unless @out.nil?
      end
    end
  end
end
