#!/usr/bin/env ruby

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hallmonitor'
require 'hallmonitor/outputters/iooutputter'
require 'hallmonitor/outputters/statsd_outputter'
require 'pry'

Hallmonitor.add_outputter Hallmonitor::Outputters::IOOutputter.new("STDOUT", STDOUT)
Hallmonitor.add_outputter Hallmonitor::Outputters::StatsdOutputter.new("example", "localhost")

class Foo
  include Hallmonitor::Monitored

  def do_something
    sleep_time_ms = ((Random.rand * 100).floor) * 2
    puts "Sleeping for #{sleep_time_ms} milliseconds"
    sleep(sleep_time_ms / 1000.0)
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
      sleep(5)
    end
  end
end

f = Foo.new

puts 'Calling method with timer_for and count_for...'
f.do_something

puts 'Emitting some events'
f.emit_events(5)

puts 'Timing a 5 second block'
f.time_me
