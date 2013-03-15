require 'hallmonitor'
require 'hallmonitor/outputters/iooutputter'
require 'hallmonitor/outputters/statsd_outputter'

Hallmonitor::Outputter.add_outputter Hallmonitor::Outputters::IOOutputter.new("STDOUT", STDOUT)
Hallmonitor::Outputter.add_outputter Hallmonitor::Outputters::StatsdOutputter.new("example", "localhost")

class Foo
  include Hallmonitor::Monitored

  def bar
    # Emit 100 events
    100.times do
      emit("event")
    end
  end

  def time_me
    watch("timed") do |x|
      sleep(10)
    end
  end
end

# Simple event with name
event = Hallmonitor::Event.new("simple")
event.emit

# Adding data to a simple event
event = Hallmonitor::Event.new("simple")
event.data = "FOOO"
event.emit

# Using a class that's monitored
foo = Foo.new
foo.bar

# Using a timed event
foo.time_me
