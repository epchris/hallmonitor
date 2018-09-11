module Hallmonitor
  # Hallmonitor configuration
  class Configuration
    # Whether or not to trap outputter exceptions, defaults to false
    attr_accessor :trap_outputter_exceptions

    # Whether or not to autoinstrument rails controller actions, defaults to false
    attr_accessor :instrument_rails_controller_actions

    # The metric name to use for controller action measurements,
    # defaults to 'controller.action.measure'
    attr_accessor :controller_action_measure_name

    # The metric name to use for controller action counts, defaults to
    # 'controller.action.measure'
    attr_accessor :controller_action_count_name

    def initialize
      @trap_outputter_exceptions = false
      @controller_action_measure_name = 'controller.action.measure'
      @controller_action_count_name = 'controller.action.count'
      @instrument_rails_controller_actions = false
    end
  end
end
