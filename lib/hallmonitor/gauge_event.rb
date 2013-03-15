module Hallmonitor
  class GaugeEvent < Event
    def initialize(name, value)
      super(name, value)
    end

    def value
      count
    end

    def value=(new_value)
      count = new_value
    end

  end
end
