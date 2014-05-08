require 'spec_helper'

class Thing
  include Hallmonitor::Monitored
end

describe Hallmonitor::Monitored do
  subject {Thing.new}

  describe "#watch" do 
    let(:retval) {"Hello World"}
    let(:name) {"foo"}
    before do 
      expect(Hallmonitor::Outputter).to receive(:output).with{|x|x.name == name}
    end
    it "should return the value the block returns" do 
      value = subject.watch(name) do 
        retval
      end
      expect(value).to eq(retval)
    end
  end

  describe "#emit" do 
    describe "with a string parameter" do 
      let(:name) {"foo"}
      before do 
        expect(Hallmonitor::Outputter).to receive(:output).with{|x|x.name == name}
      end
      
      it "should emit an event with the passed in name" do
        subject.emit(name)
      end
    end

    describe "with a block" do
      it "should yield to the block" do
        yielded = false
        var = nil
        subject.emit("foo") do |thing|
          var = thing
          yielded = true
        end
        expect(var).to_not be_nil
        expect(var.name).to eq("foo")
        expect(yielded).to be_true
      end
    end

    describe 'with an event parameter' do 
      let(:event) {Hallmonitor::Event.new("bar")}
      before do 
        expect(Hallmonitor::Outputter).to receive(:output).with(event)
      end
      
      it "should emit the passed in event" do
        subject.emit(event)
      end
    end

  end
end
