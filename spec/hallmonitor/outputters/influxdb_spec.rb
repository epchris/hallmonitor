require 'spec_helper'
require 'hallmonitor/outputters/influxdb'

module Hallmonitor
  module Outputters
    RSpec.describe InfluxdbOutputter do
      let(:influxdb_client) { nil }
      let(:default_tags) { {} }
      let(:outputter) { described_class.new(influxdb_client, default_tags) }

      context '#initialize' do
        context 'with a bad influxdb client' do
          it 'raises an error' do
            expect { outputter }.to raise_error(String)
          end
        end

        context 'with a good client' do
          let(:influxdb_client) { double('influxdb_client') }
          before do
            allow(influxdb_client).to receive(:write_point)
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
            tags: default_tags.merge(tags).merge(type: expected_type)
          }
        end

        it 'sends the correct information to influxdb' do
          expect(influxdb_client).to(
            receive(:write_point).with(event_name, expected_data))
          outputter.process(event)
        end

        context 'with a timer event' do
          let(:event) { Hallmonitor::TimedEvent.new(event_name, 100, tags: tags) }
          let(:expected_value) { event.duration }
          let(:expected_type) { 'timer' }
          it 'sends the correct information to influxdb' do
            expect(influxdb_client).to(
              receive(:write_point).with(event_name, expected_data))
            outputter.process(event)
          end
        end

        context 'with a gauge event' do
          let(:event) { Hallmonitor::GaugeEvent.new(event_name, 100, tags: tags) }
          let(:expected_value) { event.value }
          let(:expected_type) { 'gauge' }
          it 'sends the correct information to influxdb' do
            expect(influxdb_client).to(
              receive(:write_point).with(event_name, expected_data))
            outputter.process(event)
          end
        end

        context 'with a name transformer' do
          let(:transformer) { double('name_transformer') }
          let(:outputter) do
            described_class.new(influxdb_client, default_tags, transformer)
          end

          it 'builds event information using the transformer' do
            expect(transformer).to(
              receive(:transform)
              .with(event.name)
              .and_return(
                name: 'foo',
                tags: { additional: 'foo' }
              )
            )
            expected_data[:tags][:additional] = 'foo'
            expect(influxdb_client).to(
              receive(:write_point).with('foo', expected_data))
            outputter.process(event)
          end
        end
      end
    end
  end
end
