require "test_helper"
require "nestor/mappers/rails/test/unit"

context "Nestor::Mappers::Rails::Test::Unit" do
  setup { Nestor::Mappers::Rails::Test::Unit.new }

  context "#map" do
    should_map \
      "app/models/user.rb"                        => ["test/unit/user_test.rb"],
      "app/models/topic.rb"                       => ["test/unit/topic_test.rb"],
      "app/models/timeline_observer.rb"           => ["test/unit/timeline_observer_test.rb", "test/unit/timeline_test.rb"],

      "app/controllers/users_controller.rb"       => ["test/functional/users_controller_test.rb"],
      "app/views/users/index.html.erb"            => ["test/functional/users_controller_test.rb"],

      "app/helpers/users_helper.rb"               => ["test/unit/helpers/users_helper_test.rb", "test/functional/users_controller_test.rb"],

      "lib/core_ext/rails/hash.rb"                => ["test/unit/core_ext/rails/hash_test.rb"],

      "test/unit/user_test.rb"                    => ["test/unit/user_test.rb"],
      "test/functional/users_controller_test.rb"  => ["test/functional/users_controller_test.rb"],
      "test/integration/signup_test.rb"           => ["test/integration/signup_test.rb"],
      "test/performance/home_page_test.rb"        => ["test/performance/home_page_test.rb"],

      # Implies running all tests under the specified directory
      "app/controllers/application_controller.rb" => ["test/functional/"],
      "app/helpers/application_helper.rb"         => ["test/unit/helpers/", "test/functional/"],

      # Implies running all tests
      "db/schema.rb"                              => [],
      "test/test_helper.rb"                       => [],
      "config/environment.rb"                     => [],
      "config/environments/test.rb"               => [],

      # Implies no tests to run
      "README.rdoc"                               => nil
  end
end

context "A Test::Unit failure after being parsed by Rails::Test::Unit" do
  setup do
    failure = Object.new
    class << failure
      def location
        ["/test/functional/api/templates_controller_test.rb:12:in `__bind_1256961206_373905'",
          "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `call'",
          "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `test: Api::TemplatesController should flunk. '",
          "/Users/francois/Projects/nestor/lib/nestor/strategies/test/unit.rb:109:in `run'"]
      end

      def test_name
        "test: Api::TemplatesController should flunk. (Api::TemplatesControllerTest)"
      end
    end

    test_files = ["test/functional/api/templates_controller_test.rb"]

    Nestor::Mappers::Rails::Test::Unit.parse_failure(failure, test_files)
  end

  should("return the filename as #first")   { topic.first }.equals("test/functional/api/templates_controller_test.rb")
  should("return the test's name as #last") { topic.last  }.equals("test: Api::TemplatesController should flunk")
end

context "A Test::Unit error after being parsed by Rails::Test::Unit" do
  setup do
    exception = RuntimeError.new("bad")
    exception.set_backtrace(["./test/functional/api/templates_controller_test.rb:12:in `__bind_1256962198_402597'",
                             "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `call'",
                             "/Library/Ruby/Gems/1.8/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/context.rb:351:in `test: Api::TemplatesController should flunk. '",
                             "/Library/Ruby/Gems/1.8/gems/activesupport-2.3.4/lib/active_support/testing/setup_and_teardown.rb:62:in `__send__'",
                             "/Library/Ruby/Gems/1.8/gems/activesupport-2.3.4/lib/active_support/testing/setup_and_teardown.rb:62:in `run'"])

    failure = Object.new
    class << failure
      attr_accessor :exception, :test_name
    end
    failure.exception = exception
    failure.test_name = "test: Api::TemplatesController should flunk. (Api::TemplatesControllerTest)"

    test_files = ["test/functional/api/templates_controller_test.rb"]

    Nestor::Mappers::Rails::Test::Unit.parse_failure(failure, test_files)
  end

  should("return the filename as #first")   { topic.first }.equals("test/functional/api/templates_controller_test.rb")
  should("return the test's name as #last") { topic.last  }.equals("test: Api::TemplatesController should flunk")
end
