require "test_helper"

context "Nestor::Script" do
  setup { Nestor::Script.new(Nestor::Mappers::Rails::Test::Unit.default_script_path) }

  asserts("has a #nestor_machine= method") { topic }.respond_to(:nestor_machine=)
end
