##
# Include this module in classes where you want monitoring capabilities
module Hallmonitor
  module Monitored
    module ClassMethods
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    ##
    # Emits an event: either self or an event if one is passed in, or constructs
    # a base event from the passed in param
    # If the parameter is a #Hallmonitor::Event, it will be emitted as is.
    # Otherwise, a new Hallmonitor::Event will be created with the parameter and emitted.
    def emit(event = nil)
      to_emit = self;
      if(!event.nil?)
        to_emit = event.kind_of?(Hallmonitor::Event) ? event : Hallmonitor::Event.new(event)
      end
      
      # If we were given a block, then we want to execute that
      if block_given?
        yield(to_emit)
      end
      
      Outputter.output(to_emit)
    end

    ##
    # Executes and times a block of code and emits a Hallmonitor::TimedEvent
    def watch(name)
      event = Hallmonitor::TimedEvent.new(name)
      event.start = Time.now
      yield(event)
      event.stop = Time.now
      emit(event)
    end
  end
end

