require 'hallmonitor/configuration'
require 'hallmonitor/dispatcher'
require 'hallmonitor/monitored'
require 'hallmonitor/event'
require 'hallmonitor/timed_event'
require 'hallmonitor/gauge_event'
require 'hallmonitor/outputter'
require 'hallmonitor/middleware'

module Hallmonitor
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Hallmonitor::Configuration.new
    yield(config)
  end
end
