# Hallmonitor

Hallmonitor is a simple event monitoring framework for Ruby.  It allows programs to define and emit events. These events can then be sent on to various back ends to be counted, monitored, etc.

Hallmonitor includes support for publishing events to a Statsd instance if the `statsd-ruby` gem is installed.  See https://github.com/reinh/statsd for details

## Setup
Before you can use Hallmonitor you have to do a tiny bit of configuration in the form of adding outputters.

```ruby
# Add an outputter to STDOUT
Hallmonitor::Dispatcher.add_outputter Hallmonitor::Outputters::IOOutputter.new("STDOUT", STDOUT)

# Add an outputter to StatsD
Hallmonitor::Dispatcher.add_outputter Hallmonitor::Outputters::StatsdOutputter.new("example", "localhost")
```

The `StatsdOutputter` is only available if you've installed the `statsd-ruby` gem.  If it's not available, StatsdOutputter's intitialize method will raise a RuntimeError

## Configuration
Right now there's only one configuration option and here's how you can set it:

```ruby
# Configure Hallmonitor
Hallmonitor.config |config|
  config.trap_outputter_exceptions = true # Default value is false
end
```

**trap_outputter_exceptions:** instructs the output framework to ignore and squash any exceptions that might be raised from inside an outputter.  This can be useful if you want to configure multiple outputter and not have a misbehaving one interrupt other outputter, or your system.

## Usage

There are a few different ways to use Hallmonitor:

### Included in your class
```ruby
class Foo
  # Monitored adds a few methods you can use, like emit(...) and watch(...)
  include Hallmonitor::Monitored

  # This method will emit 100 events
  def bar

    # Emit 100 events.  The string will be the name of the Event object that gets emitted
    100.times do
      emit("event") # Will emit a new Event with the name 'event'
    end

    # You can also just emit Event objects themselves
    emit(Event.new("new_event"))

    # emit also takes a block, if you want to modify the event before it is emitted
    emit(Event.new("event")) do |e|
      e.name = "changed"
    end
  end

  # This method will emit 1 TimedEvent for the block with the name 'timed'
  def time_me
    watch("timed") do
      sleep(10)
    end
  end
end

foo = Foo.new
foo.bar # Will emit 10 events
foo.time_me # Will emit a single TimedEvent
```

### Explicit Event objects
```ruby
# Event objects include Hallmonitor::Monitored and so they have
# an emit method of their own
event = Hallmonitor::Event.new("event")
event.emit
```

## Contributing to Hallmonitor

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012-2015 Chris TenHarmsel. See LICENSE.txt for
further details.
