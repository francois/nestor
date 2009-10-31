require File.dirname(__FILE__) + "/spec_helper"
require "nestor/strategies/test/unit"

describe Nestor::Strategies::Test::Unit, "#parse_failure" do
  it "should return the file and test name as reported by a failure" do
    failure = mock
    failure.stub(:location).and_return(
      ["/test/functional/api/templates_controller_test.rb:12:in `__bind_1256961206_373905'",
        "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `call'",
        "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `test: Api::TemplatesController should flunk. '",
        "/Users/francois/Projects/nestor/lib/nestor/strategies/test/unit.rb:109:in `run'"])
    failure.stub(:test_name).and_return("test: Api::TemplatesController should flunk. (Api::TemplatesControllerTest)")

    test_files = ["test/functional/api/templates_controller_test.rb"]

    filename, test_name = Nestor::Strategies::Test::Unit.parse_failure(failure, test_files)

    filename.should  == "test/functional/api/templates_controller_test.rb"
    test_name.should == "test: Api::TemplatesController should flunk"
  end
end
