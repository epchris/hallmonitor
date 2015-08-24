require 'hallmonitor/monitored'
module Hallmonitor
  # The event class is a single-fire event, it most often
  # represents a single, countable metric.
  class Event
    include Hallmonitor::Monitored

    attr_accessor :name, :time, :count, :tags

    # Builds a new event
    # @param name [String] the name of this event
    # @param count [Number] the count of this even, defaults to 1
    def initialize(name, count=1, tags: {})
      @name = name
      @time = Time.now
      @count = count
      @tags = tags
    end

    def to_json(*a)
      {
        name: @name,
        time: @time,
        count: @count,
        tags: @tags
      }.to_json(*a)
    end
  end
end
