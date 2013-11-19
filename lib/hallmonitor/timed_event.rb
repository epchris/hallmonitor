module Hallmonitor
  class TimedEvent < Event
    attr_accessor :start, :stop

    def initialize(name, duration=nil)
      super(name)
      @duration = duration
    end

    # Duration, should be set in ms, will take precedence over
    # calculating via start and stop times
    attr_writer :duration

    # Reports duration of this timed event in ms
    def duration
      if @duration
        @duration
      elsif @start && @stop
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
