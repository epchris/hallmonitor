require 'spec_helper'
module Hallmonitor
  RSpec.describe Dispatcher do
    let(:outputter) { instance_double(Hallmonitor::Outputter) }
    before do
      allow(outputter).to receive(:process)
      Dispatcher.add_outputter(outputter)
    end

    after do
      Dispatcher.clear_outputters
    end

    describe "managing outputters" do
      it 'tracks outputters' do
        expect(Dispatcher.outputters).to include(outputter)
      end
    end

    describe '#output' do
      it 'dispatches to outputters' do
        expect(outputter).to receive(:process).with("thing")
        Dispatcher.output("thing")
      end

      describe 'with exception trapping turned off' do
        let(:error) { "FOOO" }
        before do
          allow(outputter).to receive(:process).and_raise(error)
          Hallmonitor.configure do |c|
            c.trap_outputter_exceptions = false
          end
        end
        it 'raises outputter exceptions' do
          expect { Dispatcher.output("thing") }.to raise_error(error)
        end
      end

      describe 'with exception trapping turned on' do
        let(:another_outputter) { instance_double(Hallmonitor::Outputter) }
        before do
          allow(outputter).to receive(:process).and_raise("FOOOOO")
          Hallmonitor.configure do |c|
            c.trap_outputter_exceptions = true
          end
          allow(another_outputter).to receive(:process)
          Dispatcher.add_outputter(another_outputter)
        end
        it 'traps outputter exceptions' do
          expect{Dispatcher.output("thing")}.to_not raise_error
        end
        it 'calls other outputters' do
          expect(another_outputter).to receive(:process).with("thing")
          expect{Dispatcher.output("thing")}.to_not raise_error
        end
      end
    end
  end
end
