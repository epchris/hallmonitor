# Version 3.0.0
- Refactored the Transformer concept in the InfluxDB outputter so that
  it is more flexible. This was in response to the InfluxDB client gem
  "fixing" a bug where numerical values were previously always sent as
  floats, now numbers are marked as "integer" type if they are ruby
  Integers which can lead to some field-type conflicts if you update
  your InfluxDB gem version and were previously sending integers at
  floats.  Using the Transformer now allows you to modify the values
  that will be sent to InfluxDB immediately before they're sent out.x
