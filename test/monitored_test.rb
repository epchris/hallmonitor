require 'helper'

class MonitoredTest < Test::Unit::TestCase
  class TestMe
    include Hallmonitor::Monitored
  end
  context "A class that includes Monitored module" do
    
    setup do
      @test_me = TestMe.new
    end
    
    should "add an emit method to instances" do
      @test_me.respond_to?(:emit)
    end
  end
end
