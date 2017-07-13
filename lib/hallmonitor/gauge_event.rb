module Hallmonitor
  # A Gauge event is an event that has a specific value,
  # think of it like a tachometer or gas gauge on a car:
  # at any given point it reports the current value of a
  # variable.
  class GaugeEvent < Event
    # @param name [String] Name of this guage
    # @param value [Number] The current value of this guage
    def initialize(name, value: nil, tags: {})
      super(name, count: value, tags: tags)
    end

    # The value of this guage
    def value
      count
    end

    # Sets the value of this guage
    # @param new_value [Number]
    def value=(new_value)
      self.count = new_value
    end

  end
end
