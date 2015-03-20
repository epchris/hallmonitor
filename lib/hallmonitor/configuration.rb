module Hallmonitor
  # Hallmonitor configuration
  class Configuration
    # Whether or not to trap outputter exceptions, defaults to false
    attr_accessor :trap_outputter_exceptions

    def initialize
      @trap_outputter_exceptions = false
    end
  end
end
