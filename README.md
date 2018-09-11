# Hallmonitor

Hallmonitor is a simple event monitoring framework for Ruby.  It allows programs to define and emit events. These events can then be sent on to various back ends to be counted, monitored, etc.

Hallmonitor includes support for the following outputters:

- [Statsd](https://github.com/reinh/statsd) - Requires the `statsd` gem to be installed
- [InfluxDB](https://github.com/influxdata/influxdb-ruby) - Requires the `influxdb` gem to be installed
- [Datadog](https://github.com/DataDog/dogstatsd-ruby) - Requires the `dogstatsd-ruby` gem to be installed
- IOOutputter - Simple outputter that outputs to an IO object
- [NewRelic](https://github.com/newrelic/rpm) - Requires the `newrelic_rpm` gem to be installed


## Setup
Before you can use Hallmonitor you have to do a tiny bit of configuration in the form of adding outputters.

```ruby
# Add an outputter to STDOUT
require 'hallmonitor/outputters/iooutputter.rb'
Hallmonitor.add_outputter Hallmonitor::Outputters::IOOutputter.new("STDOUT", STDOUT)

# Add an outputter to StatsD
require 'hallmonitor/outputters/statsd_outputter'
Hallmonitor.add_outputter Hallmonitor::Outputters::StatsdOutputter.new("example", "localhost")

# Add an outputter to Datadog
require 'hallmonitor/outputters/datadog
datadog = Datadog::Statsd.new
Hallmonitor.add_outputter Hallmonitor::Outputters::Datadog.new(datadog)
```

## Configuration
There are a few configuration options, two of which are only
applicable when used within rails.  You can configure their values like so:

```ruby
# Configure Hallmonitor
Hallmonitor.config |config|
  config.trap_outputter_exceptions = true # Default value is false
  config.instrument_rails_controller_actions = true # Default value is false
  config.controller_action_measure_name = 'controller.action.measure' # this is the default
  config.controller_action_count_name = 'controller.action.count' # this is the default
end
```

* **trap_outputter_exceptions:** instructs the output framework to ignore and squash any exceptions that might be raised from inside an outputter.  This can be useful if you want to configure multiple outputter and not have a misbehaving one interrupt other outputter, or your system.
* **instrument_rails_controller_actions:** Whether or not to auto instrument rails controller actions, defaults to false
* **controller_action_measure_name:** the metric name to use for the auto-instrumented metric for rails actions that include time measurements
* **controller_action_count_name:** the metric name to use for the auto-instrumented metric for rails actions that tracks action invocation counts

## Usage

There are a few different ways to use Hallmonitor:

## Rails Autoinstrumentation

If `config.instrument_rails_controller_actions` is true, and Rails is
defined Hallmonitor will define a Railtie that auto-instruments all
rails controller actions to collect execution duration and count
information.  You can see details of the metrics gathered in the
`hallmonitor/railtie.rb` file.

You can configure the metric names that are used via the
`config.controller_action_measure_name` and
`config.controller_action_count_name` configuration directives.


### Included in your class

The easiest way is to include `Hallmonitor::Monitored` in your class
and use its `emit(...)` and `watch(...)` methods.  `emit` emits a
single count metric with a name and optional tags, while `watch`
executes the provided block and emits a `Hallmonitor::TimedEvent` with
the duration that the block took to execute.

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

You can also construct and manually emit a `Hallmonitor::Event` object
if you need to:

```ruby
event = Hallmonitor::Event.new("event")
event.emit
```

## Contributing to Hallmonitor

* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012-2018 Chris TenHarmsel. See LICENSE.txt for
further details.
