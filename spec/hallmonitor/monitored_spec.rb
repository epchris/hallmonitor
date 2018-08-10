require 'spec_helper'

class Thing
  include Hallmonitor::Monitored

  def timer_for_test
    # Nothing
  end
  timer_for :timer_for_test, metric_name: 'thing.measure', tags: {foo: 'bar'}

  def count_for_test
    # Nothing
  end
  count_for :count_for_test, metric_name: 'thing.execute', tags: {foo: 'bar'}
end

RSpec::Matchers.define :an_event do
  match { |actual| actual.is_a?(Hallmonitor::Event)}
end

RSpec::Matchers.define :a_timed_event do
  match { |actual| actual.is_a?(Hallmonitor::Event)}
end

RSpec::Matchers.define :has_name do |expected_name|
  match { |actual| actual.name == expected_name }
end

RSpec::Matchers.define :has_tags do |expected_tags|
  match { |actual| actual.tags == expected_tags}
end

RSpec.describe Hallmonitor::Monitored do
  subject { Thing.new }

  describe '#timer_for' do
    it 'emits a timer with an appropriate name' do
      expect(Hallmonitor::Dispatcher).to(
        receive(:output)
          .with(
            a_timed_event.and(has_name('thing.measure')).and(has_tags({foo: 'bar'}))
          )
      )
      Thing.new.timer_for_test
    end
  end

  describe '#count_for' do
    it 'emits an event with an appropriate name' do
      expect(Hallmonitor::Dispatcher).to(
        receive(:output).with(
          an_event.and(has_name('thing.execute')).and(has_tags({foo: 'bar'}))
        )
      )
      Thing.new.count_for_test
    end
  end

  shared_examples 'for watch' do
    let(:retval) { 'Hello World' }
    let(:name) { 'foo' }

    it 'returns the value the block returns' do
      value = subject.watch(name) { retval }
      expect(value).to eq(retval)

      value = subject.watch(name) { nil }
      expect(value).to_not be
    end

    it 'emits a timer event for the block' do
      expect(Hallmonitor::Dispatcher).to(
        receive(:output).with(
          an_event.and(has_name(name))
        )
      )
      subject.watch(name) { 'foo' }
    end

    describe 'with tags' do
      let(:name) { 'foo'}
      let(:tags) { {'foo': 'bar', 'baz': 6}}

      it 'emits an event with tags' do
        expect(Hallmonitor::Dispatcher).to(
          receive(:output).with(
            an_event.and(has_tags(tags))
          )
        )
        subject.watch(name, tags: tags) { 'foo' }
      end
    end

    describe 'when the block raises an error' do
      it 'emits a timer for the block' do
        expect(Hallmonitor::Dispatcher).to(
          receive(:output).with(
            a_timed_event.and(has_name(name))
          )
        )
        expect do
          subject.watch(name) { fail 'OOPS!' }
        end.to raise_error('OOPS!')
      end
    end
  end

  shared_examples 'for emit' do
    describe 'with a string parameter' do
      let(:name) { 'foo' }

      it 'emits an event with the passed in name' do
        expect(Hallmonitor::Dispatcher).to(
          receive(:output).with(
            an_event.and(has_name(name))
          )
        )

        subject.emit(name)
      end
    end

    describe 'with tags' do
      let(:name) { 'foo'}
      let(:tags) { {'foo' => 'bar', 'baz' => 6}}

      it 'emits an event with tags' do
        expect(Hallmonitor::Dispatcher).to(
          receive(:output).with(
            an_event.and(has_tags(tags)).and(has_name(name))
          )
        )
        subject.emit(name, tags: tags)
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
        expect(Hallmonitor::Dispatcher).to receive(:output).with(event)
        subject.emit(event)
      end
    end
  end

  context 'Instance' do
    subject { Thing.new }
    context '#watch' do
      include_examples 'for watch'
    end

    context '#emit' do
      include_examples 'for emit'
    end
  end

  context 'Class' do
    subject { Thing }
    context '.watch' do
      include_examples 'for watch'
    end

    context '.emit' do
      include_examples 'for emit'
    end
  end
end
