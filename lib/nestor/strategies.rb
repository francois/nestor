module Nestor
  # Nestor::Cli will require a file named +nestor/strategies/#{strategy_name}+.  If you want
  # to provide custom strategies, make it available to Nestor using the correct path.
  #
  # Strategies are simple objects that implement the following protocol:
  #
  # <tt>log(message)</tt>:: Logs a simple message, either to the console or a logfile.
  #                         The Machine will use the +log+ method to notify about it's
  #                         state transitions.
  #
  # <tt>run_all</tt>:: Runs all the tests, no matter what.  In the Rails &
  #                    +Test::Unit+ case, this means <tt>Dir["test/**/*_test.rb"]</tt>.
  #
  # <tt>run(tests_files, focused_cases=[])</tt>:: Runs only a subset of the tests, maybe
  #                                               focusing on only a couple of tests / examples.
  module Strategies
  end
end
