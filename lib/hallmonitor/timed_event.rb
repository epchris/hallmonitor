module Hallmonitor
  # An event that represents a span of time
  class TimedEvent < Event
    # @!attribute start
    #   @return [DateTime] the start time of this timed event
    # @!attribute stop
    #   @return [DateTime] the stop time of this timed event

    attr_accessor :start, :stop

    # Builds a new {TimedEvent}
    # @param name [String] name of this event
    # @param duration [Number] the timespan of this event
    def initialize(name, duration=nil)
      super(name)
      @duration = duration
    end

    # @!attribute [w] duration
    #   Duration, should be set in ms, will take precedence over
    #   calculating via start and stop times
    #   @return [Number] the currently value of duration
    attr_writer :duration

    # Reports duration of this timed event in ms
    # @return [Number] duration, in ms if calculated based on
    #   {#start} and {#stop}
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
