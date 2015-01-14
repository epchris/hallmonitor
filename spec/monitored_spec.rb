require 'spec_helper'

class Thing
  include Hallmonitor::Monitored

  def timer_for_test
    # Nothing
  end
  timer_for :timer_for_test

  def count_for_test
    # Nothing
  end
  count_for :count_for_test
end

RSpec::Matchers.define :an_event_with_name do |expected_name|
  match { |actual| actual.is_a?(Hallmonitor::Event) && actual.name == expected_name }
end

RSpec::Matchers.define :a_timed_event_with_name do |expected_name| 
  match { |actual| actual.is_a?(Hallmonitor::TimedEvent) && actual.name == expected_name }
end

describe Hallmonitor::Monitored do
  subject { Thing.new }

  describe '#timer_for' do
    it 'should emit a timer with an appropriate name' do
      expect(Hallmonitor::Outputter).to(
        receive(:output).with(a_timed_event_with_name('thing.timer_for_test')))
      Thing.new.timer_for_test
    end
  end

  describe '#count_for' do
    it 'should emit an event with an appropriate name' do
      expect(Hallmonitor::Outputter).to(
        receive(:output).with(an_event_with_name('thing.count_for_test')))
      Thing.new.count_for_test
    end
  end

  describe '#watch' do
    let(:retval) { 'Hello World' }
    let(:name) { 'foo' }
    before do
      expect(Hallmonitor::Outputter).to receive(:output).with(a_timed_event_with_name(name))
    end
    it 'should return the value the block returns' do
      value = subject.watch(name) do
        retval
      end
      expect(value).to eq(retval)
    end
  end

  describe '#emit' do
    describe 'with a string parameter' do
      let(:name) {"foo"}
      before do
        expect(Hallmonitor::Outputter).to receive(:output).with(an_event_with_name(name))
      end

      it "should emit an event with the passed in name" do
        subject.emit(name)
      end
    end

    describe 'with a block' do
      it 'should yield to the block' do
        yielded = false
        var = nil
        subject.emit('foo') do |thing|
          var = thing
          yielded = true
        end
        expect(var).to_not be_nil
        expect(var.name).to eq('foo')
        expect(yielded).to be_truthy
      end
    end

    describe 'with an event parameter' do
      let(:event) { Hallmonitor::Event.new('bar') }
      before do
        expect(Hallmonitor::Outputter).to receive(:output).with(event)
      end

      it 'should emit the passed in event' do
        subject.emit(event)
      end
    end

  end
end
