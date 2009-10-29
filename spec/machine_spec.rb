require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Nestor::Machine do
  it "should accept a strategy on instantiation" do
    strategy = mock.as_null_object
    machine = Nestor::Machine.new(strategy)
    machine.strategy.should be_equal(strategy) 
  end
end

describe Nestor::Machine do
  before(:each) do
    @strategy = mock
    @strategy.stub(:run_all)
  end

  it "should start in the :running_all state" do
    @machine = Nestor::Machine.new(@strategy)
    machine.should be_running_all
  end

  it "should tell the strategy to run all tests" do
    strategy = mock
    strategy.should_receive(:run_all).with().once
    Nestor::Machine.new(strategy)
  end

  it "should transition to :green when calling #successful" do
    machine.successful
    machine.should be_green
  end

  it "should transition to :run_focused when calling #failed" do
    machine.failed
    machine.should be_run_focused
  end

  def machine
    @machine ||= Nestor::Machine.new(@strategy)
  end
end

describe Nestor::Machine, "when in the run_focused state" do
  before(:each) do
    @strategy = mock
    @strategy.stub(:run_all)
    @machine = Nestor::Machine.new(@strategy)
    @machine.failed
  end

  it "should transition to :running_focused when calling #changed!(filename)" do
    @strategy.should_receive(:run).with(["spec/machine_spec.rb"])
    @machine.changed!("spec/machine_spec.rb")
    @machine.should be_running_focused
  end
end
