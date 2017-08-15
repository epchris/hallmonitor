require 'spec_helper'
require 'hallmonitor/outputters/dogstatsd_outputter'

module Hallmonitor
  module Outputters
    RSpec.describe DogstatsdOutputter do
      let(:dogstatsd_client) { instance_double(Datadog::Statsd) }
      let(:prefix) { 'test' }
      let(:outputter) { described_class.new(prefix) }

      before do
        allow(dogstatsd_client).to receive(:namespace=)
        allow(Datadog::Statsd).to receive(:new).and_return(dogstatsd_client)
      end

      it 'can be instantiated' do
        expect { outputter }.to_not raise_error
      end

      context '#process' do
        let(:event_name) { 'foo.bar.baz' }
        let(:event_tags) { {tags: [{foo:"bar"}]} }
        let(:event_tags_expected) {{tags:["tags:[{:foo=>\"bar\"}]"]}}
        context 'with an event' do
          let(:event) { Event.new(name = event_name, tags: event_tags) }

          it 'sends the event to statsd' do
            expect(dogstatsd_client).to receive(:count).with(event_name, event.count, event_tags_expected)
            outputter.process(event)
          end

          context 'that has multiple values' do
            let(:values) { { foo: 1, bar: 2 } }
            let(:event) { Event.new(event_name, count: values, tags: event_tags) }
            it 'sends multiple events to statsd' do
              expect(dogstatsd_client).to receive(:count).with("#{event_name}.foo", event.count[:foo], event_tags_expected)
              expect(dogstatsd_client).to receive(:count).with("#{event_name}.bar", event.count[:bar], event_tags_expected)
              outputter.process(event)
            end
          end
        end
      end
    end
  end
end
