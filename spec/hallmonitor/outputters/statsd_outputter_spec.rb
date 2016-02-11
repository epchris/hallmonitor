require 'spec_helper'

require 'hallmonitor/outputters/statsd_outputter'

module Hallmonitor
  module Outputters
    RSpec.describe StatsdOutputter do
      let(:statsd_client) { instance_double(Statsd) }
      let(:prefix) { 'test' }
      let(:outputter) { described_class.new(prefix) }

      before do
        allow(statsd_client).to receive(:namespace=)
        allow(Statsd).to receive(:new).and_return(statsd_client)
      end

      it 'can be instantiated' do
        expect { outputter }.to_not raise_error
      end

      context '#process' do
        let(:event_name) { 'foo.bar.baz' }
        context 'with an event' do
          let(:event) { Event.new(event_name) }

          it 'sends the event to statsd' do
            expect(statsd_client).to receive(:count).with(event_name, event.count)
            outputter.process(event)
          end

          context 'that has multiple values' do
            let(:values) { { foo: 1, bar: 2 } }
            let(:event) { Event.new(event_name, count: values) }
            it 'sends multiple events to statsd' do
              expect(statsd_client).to receive(:count).with("#{event_name}.foo", event.count[:foo])
              expect(statsd_client).to receive(:count).with("#{event_name}.bar", event.count[:bar])
              outputter.process(event)
            end
          end
        end
      end
    end
  end
end
