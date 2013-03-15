require 'hallmonitor/monitored'
module Hallmonitor
  ##
  # The event class is a single-fire event
  class Event
    include Hallmonitor::Monitored
    
    attr_accessor :name, :time, :data, :count
    
    def initialize(name, count=1, data=nil)
      @name = name
      @data = data
      @time = Time.now
      @count = count
    end

    def to_json(*a)
      {
        name: @name,
        data: @data,
        time: @time,
        count: @count
      }.to_json(*a)
    end
  end
end
