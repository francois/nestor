require "test_helper"
require "nestor/mappers/rails"

context "Nestor::Mappers::Rails" do
  setup { Nestor::Mappers::Rails.new }

  context "#map" do
    should_map \
      'app/models/user.rb'                       => ["test/unit/user_test.rb"],
      'app/models/topic.rb'                      => ["test/unit/topic_test.rb"],
      'app/controllers/users_controller.rb'      => ["test/functional/users_controller_test.rb"],
      'app/views/users/index.html.erb'           => ["test/functional/users_controller_test.rb"],
      'lib/core_ext/rails/hash.rb'               => ["test/unit/core_ext/rails/hash_test.rb"],
      'db/schema.rb'                             => ["db/schema.rb"],
      'test/unit/user_test.rb'                   => ["test/unit/user_test.rb"],
      'test/functional/users_controller_test.rb' => ["test/functional/users_controller_test.rb"],
      'test/integration/signup_test.rb'          => ["test/integration/signup_test.rb"],
      'test/performance/home_page_test.rb'       => ["test/performance/home_page_test.rb"],
      'app/models/timeline_observer.rb'          => ["test/unit/timeline_observer_test.rb", "test/unit/timeline_test.rb"]
  end
end
