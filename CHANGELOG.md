# Version 5.1.0
## Changes
- Introduced Rails autoinstrumentation for Controller Actions.  Only
  applied if Rails is present and the configuration parameter
  `instrument_rails_controller_actions` is set to true.

# Version 5.0.0
## Breaking changes
- Renamed `Hallmonitor::Outputters::DogstatsdOutputter` to
  `Hallmonitor::Outputters::Dogstatsd`
- Changed initialization parameters to `Dogstatsd` to take in a
  `Datadog::Statsd` instance instead of initializing one
- Changed visibility of the `Dogstatsd#process_tags` method to private
- Changed `Hallmonitor::Monitored#timer_for`
  and`Hallmonitor::Monitored#count_for` so that they use kwargs and
  support specifying tags
- Changed `Hallmonitor::Monitored` so that when included it instructs
  the including class to also extend the module so that class-level
  `emit` and `watch` methods are available
## Other Changes
- `Hallmonitor::TimedEvent#to_json` now includes tags
- `Hallmonitor::GaugeEvent` now implements `to_json`

# Verison 4.2.0
- Added Dogstatsd outputter, thanks to mlahaye

# Version 4.0.0
- Changed initializer signature for InfluxDB outputter to use
  keyword args.
- Added `attr_accessor` for InfluxDB Outputter's transformer

# Version 3.0.0
- Refactored the Transformer concept in the InfluxDB outputter so that
  it is more flexible. This was in response to the InfluxDB client gem
  "fixing" a bug where numerical values were previously always sent as
  floats, now numbers are marked as "integer" type if they are ruby
  Integers which can lead to some field-type conflicts if you update
  your InfluxDB gem version and were previously sending integers at
  floats.  Using the Transformer now allows you to modify the values
  that will be sent to InfluxDB immediately before they're sent out.x
