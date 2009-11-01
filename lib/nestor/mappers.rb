module Nestor
  # {Nestor::Cli} will require a file named +nestor/mappers/#{framework}/#{test_framework}+.  If you want
  # to provide custom mappers, it is possible to do so.
  #
  # Mappers are simple objects that implement the following protocol:
  #
  # <tt>log(message)</tt>:: Logs a simple message, either to the console or a logfile.
  #                         The {Nestor::Machine} will use the +log+ method to notify about it's
  #                         state transitions.
  #
  # <tt>run_all</tt>:: Runs all the tests, no matter what.  In the {Nestor::Mappers::Rails::Test::Unit}
  #                    case, this means <tt>Dir["test/**/*_test.rb"]</tt>.
  #
  # <tt>run(tests_files, focused_cases=[])</tt>:: Runs only a subset of the tests, maybe
  #                                               focusing on only a couple of tests / examples.
  #
  # <tt>map(file)</tt>:: Given an implementation file, returns the corresponding test to run.
  #                      {Nestor::Mappers::Rails::Test::Unit} maps +app/models/user.rb+ to
  #                      +test/unit/user_test.rb+.
  module Mappers
  end
end
