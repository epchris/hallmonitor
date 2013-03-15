module Hallmonitor
  class TimedEvent < Event
    attr_accessor :start, :stop

    # Reports duration of this timed even in ms
    def duration
      if @start && @stop
        (@stop - @start) * 1000
      end
    end

    def to_json(*a)
      {
        name: @name,
        time: @time,
        start: @start,
        stop:  @stop,
        duration: self.duration
      }.to_json(*a)
    end
  end
end
