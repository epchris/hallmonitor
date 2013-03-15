require 'hallmonitor/monitored'
module Hallmonitor
  ##
  # The event class is a single-fire event
  class Event
    include Hallmonitor::Monitored
    
    attr_accessor :name, :time, :count
    
    def initialize(name, count=1)
      @name = name
      @time = Time.now
      @count = count
    end

    def to_json(*a)
      {
        name: @name,
        time: @time,
        count: @count
      }.to_json(*a)
    end
  end
end
