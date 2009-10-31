require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Nestor::Machine do
  it "should accept a strategy on instantiation" do
    strategy = mock.as_null_object
    machine = Nestor::Machine.new(strategy)
    machine.strategy.should be_equal(strategy) 
  end
end
