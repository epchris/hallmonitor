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

RSpec.describe Hallmonitor::Monitored do
  subject { Thing.new }

  describe '#timer_for' do
    it 'emits a timer with an appropriate name' do
      expect(Hallmonitor::Outputter).to(
        receive(:output).with(a_timed_event_with_name('thing.timer_for_test')))
      Thing.new.timer_for_test
    end
  end

  describe '#count_for' do
    it 'emits an event with an appropriate name' do
      expect(Hallmonitor::Outputter).to(
        receive(:output).with(an_event_with_name('thing.count_for_test')))
      Thing.new.count_for_test
    end
  end

  describe '#watch' do
    let(:retval) { 'Hello World' }
    let(:name) { 'foo' }

    it 'returns the value the block returns' do
      value = subject.watch(name) do
        retval
      end
      expect(value).to eq(retval)

      value = subject.watch(name) do
        nil
      end
      expect(value).to_not be
    end

    it 'emits a timer event for the block' do
      expect(Hallmonitor::Outputter).to(
        receive(:output).with(a_timed_event_with_name(name)))
      subject.watch(name) do
        'foo'
      end
    end

    describe 'when the block raises an error' do
      it 'emits a timer for the block' do
        expect(Hallmonitor::Outputter).to(
          receive(:output).with(a_timed_event_with_name(name)))
        expect {
          subject.watch(name) do
            raise 'OOPS!'
          end
        }.to raise_error
      end
    end
  end

  describe '#emit' do
    describe 'with a string parameter' do
      let(:name) { 'foo' }

      it 'emits an event with the passed in name' do
        expect(Hallmonitor::Outputter).to(
          receive(:output).with(an_event_with_name(name)))
        subject.emit(name)
      end
    end

    describe 'with a block' do
      it 'yields to the block' do
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

      it 'emits the passed in event' do
        expect(Hallmonitor::Outputter).to receive(:output).with(event)
        subject.emit(event)
      end
    end

  end
end
