##
# Include this module in classes where you want monitoring capabilities
module Hallmonitor
  module Monitored
    module ClassMethods
      def timer_for(method_sym, options = {})
        metric_name = options[:metric_name] || "#{underscore(name)}.#{method_sym}"
        send(:define_method, "#{method_sym}_with_hallmonitor_timer") do |*args|
          watch(metric_name) do
            send("#{method_sym}_without_hallmonitor_timer".to_sym, *args)
          end
        end

        alias_method "#{method_sym}_without_hallmonitor_timer".to_sym, method_sym
        alias_method method_sym, "#{method_sym}_with_hallmonitor_timer".to_sym
      end

      def count_for(method_sym, options = {})
        metric_name = options[:metric_name] || "#{underscore(name)}.#{method_sym}"
        send(:define_method, "#{method_sym}_with_hallmonitor_counter") do |*args|
          emit(metric_name)
          send("#{method_sym}_without_hallmonitor_counter".to_sym, *args)
        end

        alias_method "#{method_sym}_without_hallmonitor_counter".to_sym, method_sym
        alias_method method_sym, "#{method_sym}_with_hallmonitor_counter".to_sym
      end

      def underscore(value)
        word = value.dup
        word.gsub!(/::/, '.')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!('-', ' ')
        word.downcase!
        word
      end
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
      unless event.nil?
        to_emit = event.kind_of?(Hallmonitor::Event) ? event : Hallmonitor::Event.new(event)
      end
      
      # If we were given a block, then we want to execute that
      yield(to_emit) if block_given?
      
      Outputter.output(to_emit)
    end

    ##
    # Executes and times a block of code and emits a Hallmonitor::TimedEvent
    def watch(name)
      event = Hallmonitor::TimedEvent.new(name)
      event.start = Time.now
      retval = yield(event)
      event.stop = Time.now
      emit(event)
      retval
    end
  end
end

