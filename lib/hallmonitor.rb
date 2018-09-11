require 'hallmonitor/configuration'
require 'hallmonitor/dispatcher'
require 'hallmonitor/monitored'
require 'hallmonitor/event'
require 'hallmonitor/timed_event'
require 'hallmonitor/gauge_event'
require 'hallmonitor/outputter'
require 'hallmonitor/middleware'
require 'hallmonitor/railtie' if defined?(Rails)

# Top-level module, allows for configuration
module Hallmonitor
  class << self
    # @return {Hallmonitor::Configuration} instance
    def config
      @config ||= Hallmonitor::Configuration.new
    end

    # Method to configure Hallmonitor, takes a block and passes a
    # {Hallmonitor::Configuration} object in, which can be used to
    # set configuration options.
    def configure
      yield(config)
    end

    # Adds an outputter to Hallmonitor.  Whenever events are emitted
    # they will be sent to all registered outputters
    #
    # @param outputter [Outputter] An instance of an outputter
    # @note This delegates to {Dispatcher.add_outputter}
    def add_outputter(outputter)
      Dispatcher.add_outputter(outputter)
    end
  end
end
