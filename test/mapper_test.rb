require "test_helper"
require "nestor/mappers/rails"

context "Nestor::Mappers::Rails" do
  setup { Nestor::Mappers::Rails.new }

  context "#map" do
    asserts("'app/models/user.rb'")                       { topic.map("app/models/user.rb") }.equals(["test/unit/user_test.rb"])
    asserts("'app/models/topic.rb'")                      { topic.map("app/models/topic.rb") }.equals(["test/unit/topic_test.rb"])
    asserts("'app/controllers/users_controller.rb'")      { topic.map("app/controllers/users_controller.rb") }.equals(["test/functional/users_controller_test.rb"])
    asserts("'app/views/users/index.html.erb'")           { topic.map("app/views/users/index.html.erb") }.equals(["test/functional/users_controller_test.rb"])
    asserts("'lib/core_ext/rails/hash.rb'")               { topic.map("lib/core_ext/rails/hash.rb") }.equals(["test/unit/core_ext/rails/hash_test.rb"])
    asserts("'db/schema.rb'")                             { topic.map("db/schema.rb") }.equals(["db/schema.rb"])
    asserts("'test/unit/user_test.rb'")                   { topic.map("test/unit/user_test.rb") }.equals(["test/unit/user_test.rb"])
    asserts("'test/functional/users_controller_test.rb'") { topic.map("test/functional/users_controller_test.rb") }.equals(["test/functional/users_controller_test.rb"])
    asserts("'test/integration/signup_test.rb'")          { topic.map("test/integration/signup_test.rb") }.equals(["test/integration/signup_test.rb"])
    asserts("'test/performance/home_page_test.rb'")       { topic.map("test/performance/home_page_test.rb") }.equals(["test/performance/home_page_test.rb"])
    asserts("'app/models/timeline_observer.rb'")          { topic.map("app/models/timeline_observer.rb") }.equals(["test/unit/timeline_observer_test.rb", "test/unit/timeline_test.rb"])
  end
end
