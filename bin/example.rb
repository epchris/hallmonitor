lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hallmonitor'
require 'hallmonitor/outputters/iooutputter'
require 'hallmonitor/outputters/statsd_outputter'
require 'pry'

Hallmonitor::Outputter.add_outputter Hallmonitor::Outputters::IOOutputter.new("STDOUT", STDOUT)
Hallmonitor::Outputter.add_outputter Hallmonitor::Outputters::StatsdOutputter.new("example", "localhost")

class Foo
  include Hallmonitor::Monitored

  def do_something
    sleep_time = (Random.rand * 20).floor
    puts "Sleeping for #{sleep_time} seconds"
    sleep(sleep_time)
  end
  timer_for :do_something
  count_for :do_something

  def emit_events(count=30)
    # Emit 100 events
    count.times do
      emit("event")
      sleep(1)
    end
  end

  def time_me
    watch("timed") do |x|
      sleep(10)
    end
  end
end

binding.pry
