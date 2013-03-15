module Hallmonitor
  class Outputter
    attr_reader :name
    @@outputters = Array.new

    def initialize(name)
      raise(ArgumentError, "Outputter expects a name") if name.nil?
      @name = name
    end

    def self.add_outputter(outputter)
      @@outputters << outputter if outputter.respond_to?(:process)
    end

    def self.output(event)
      @@outputters.each do |o|
        o.process(event)
      end
    end

    def process(event)
      # Nothing
    end
  end
end
