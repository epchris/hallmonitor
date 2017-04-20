require 'spec_helper'
require 'hallmonitor/outputters/influxdb'

module Hallmonitor
  module Outputters
    RSpec.describe Influxdb do
      let(:influxdb_client) { nil }
      let(:default_tags) { {} }
      let(:outputter) do
        described_class.new(influxdb_client, tags: default_tags)
      end

      context '#initialize' do
        context 'with a bad influxdb client' do
          it 'raises an error' do
            expect { outputter }.to raise_error
          end
        end

        context 'with a good client' do
          let(:influxdb_client) { instance_double(InfluxDB::Client) }
          before do
            allow(influxdb_client).to receive(:write_point)
            allow(influxdb_client).to(
              receive(:config)
                .and_return(double(time_precision: 'ms'))
            )
          end

          it 'does not raise an error' do
            expect { outputter }.to_not raise_error
          end
        end
      end

      context '#process' do
        let(:default_tags) { { foo: 'bar' } }
        let(:influxdb_client) { double('influxdb_client') }
        let(:event_name) { 'event_name' }
        let(:event) { Hallmonitor::Event.new(event_name, tags: tags) }
        let(:tags) { { tag_one: 'one', tag_two: 'two' } }
        let(:expected_value) { event.count }
        let(:expected_type) { 'count' }
        let(:expected_data) do
          {
            values: { value: expected_value },
            tags: default_tags.merge(tags).merge(type: expected_type),
            timestamp: a_value_within(1000).of((Time.now.to_r * 10**3).to_i)
          }
        end

        before do
          allow(influxdb_client).to(
            receive(:config)
              .and_return(double(time_precision: 'ms'))
          )
        end

        it 'sends the correct information to influxdb' do
          expect(influxdb_client).to(
            receive(:write_point).with(event_name, expected_data))
          outputter.process(event)
        end

        context 'with a timer event' do
          let(:event) { Hallmonitor::TimedEvent.new(event_name, duration: 100, tags: tags) }
          let(:expected_value) { event.duration }
          let(:expected_type) { 'timer' }
          it 'sends the correct information to influxdb' do
            expect(influxdb_client).to(
              receive(:write_point).with(event_name, expected_data))
            outputter.process(event)
          end
        end

        context 'with a gauge event' do
          let(:event) { Hallmonitor::GaugeEvent.new(event_name, value: 100, tags: tags) }
          let(:expected_value) { event.value }
          let(:expected_type) { 'gauge' }
          it 'sends the correct information to influxdb' do
            expect(influxdb_client).to(
              receive(:write_point).with(event_name, expected_data))
            outputter.process(event)
          end
        end

        context 'with a transformer' do
          let(:transformer) { double('transformer') }
          let(:outputter) do
            described_class.new(influxdb_client, tags: default_tags, transformer: transformer)
          end

          let(:expected_data) do
            {
              values: { value: expected_value },
              tags: { additional: 'foo' },
              timestamp: nil
            }
          end

          it 'builds event information using the transformer' do
            expect(transformer).to(
              receive(:transform)
                .with(event, anything)
                .and_return(
                  Influxdb::EventData.new(
                    'foo',
                    { additional: 'foo' },
                    value: 1
                  )
                )
            )
            expect(influxdb_client).to(
              receive(:write_point).with('foo', expected_data))
            outputter.process(event)
          end
        end
      end
    end
  end
end
