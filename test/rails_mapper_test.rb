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
