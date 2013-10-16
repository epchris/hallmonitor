require 'hallmonitor/outputter'

module Hallmonitor
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      @event_base_name = "http.#{request.path_info.gsub('/', '.')}.#{request.request_method}"
      unless request.path_info.match(/^\/?assets/)
        @event = Hallmonitor::TimedEvent.new("#{@event_base_name}.response_time")
        @event.start = Time.now
      end

      response = @app.call(env)

      if @event
        @event.stop = Time.now
        Hallmonitor::Outputter.output(@event)
        Hallmonitor::Outputter.output(Hallmonitor::Event.new("#{@event_base_name}.count"))
      end
      response
    end
  end
end
