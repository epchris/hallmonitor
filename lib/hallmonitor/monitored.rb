##
# Include this module in classes where you want monitoring capabilities
module Hallmonitor
  module Monitored
    module ClassMethods
      # Sets up a timer for a method by symbol.  Method must have already been
      # defined (ie. put this after the method definition)
      # @param method_sym [Symbol] method name as a symbol
      # @options [Hash] Optional settings:
      #   metric_name: [String] Metric name to emit, defaults to
      #   "#{underscore(name)}.#{method_sym}"
      def timer_for(method_sym, metric_name: nil, tags: {})
        metric_name ||= "#{underscore(name)}.#{method_sym}"
        undecorated_method_sym = "#{method_sym}_without_hallmonitor_timer".to_sym
        decorated_method_sym = "#{method_sym}_with_hallmonitor_timer".to_sym
        send(:define_method, decorated_method_sym) do |*args|
          watch(metric_name, tags: tags) do
            send(undecorated_method_sym, *args)
          end
        end

        alias_method undecorated_method_sym, method_sym
        alias_method method_sym, decorated_method_sym
      end

      # Sets up a counter for a method by symbol.  Method must have already been
      # defined (ie. put this after the method definition)
      # @param method_sym [Symbol] method name as a symbol
      # @options [Hash] Optional settings:
      #   metric_name: [String] Metric name to emit, defaults to
      #   "#{underscore(name)}.#{method_sym}"
      def count_for(method_sym, metric_name: nil, tags: {})
        metric_name ||= "#{underscore(name)}.#{method_sym}"
        undecorated_method_sym = "#{method_sym}_without_hallmonitor_counter".to_sym
        decorated_method_sym = "#{method_sym}_with_hallmonitor_counter".to_sym
        send(:define_method, decorated_method_sym) do |*args|
          emit(metric_name, tags: tags)
          send(undecorated_method_sym, *args)
        end

        alias_method undecorated_method_sym, method_sym
        alias_method method_sym, decorated_method_sym
      end

      # :reek:UtilityFunction
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
      base.extend(self)
    end

    # Emits an event: self if the event param is nil, the passed in
    # event if it's an {Event}, or constructs a {Event} from the
    # passed in param.
    #
    # If the parameter is a {Hallmonitor::Event}, it will be emitted
    # as is.  Otherwise, a new {Hallmonitor::Event} will be created
    # with the parameter and emitted.
    #
    # @param event [Mixed] The thing to emit, see method description
    # @yield [to_emit] The thing that's going to be emitted
    def emit(event = nil, tags: {})
      to_emit = self
      unless event.nil?
        to_emit = event.is_a?(Hallmonitor::Event) ? event : Hallmonitor::Event.new(event, tags: tags)
      end

      # If we were given a block, then we want to execute that
      yield(to_emit) if block_given?

      Dispatcher.output(to_emit)
      nil
    end

    # Executes and times a block of code and emits a {TimedEvent}
    # @note Will emit the timed event even if the block raises an error
    # @param name [String] The name of the event to emit
    # @yield [event] the event object that will be emitted
    # @return Whatever the block's return value is
    def watch(name, tags: {})
      event = Hallmonitor::TimedEvent.new(name, tags: tags)
      event.start = Time.now
      begin
        yield(event)
      ensure
        event.stop = Time.now
        emit(event)
      end
    end
  end
end
