require "state_machine"

module Nestor
  # Implements the state machine that controls Nestor.
  class Machine
    # Machine actually delegates running the tests to another object, and this is it's reference.
    attr_reader :strategy

    # The list of changed files, as received by #changed!
    attr_reader :changed_files

    # The last changed file.  Set by #changed!
    attr_reader :changed_file

    # The list of tests/specs being focused on right now
    attr_reader :focuses

    def initialize(strategy)
      super() # Have to specify no-args, or else it'll raise an ArgumentError

      @strategy = strategy
      @changed_files, @focuses = [], []

      log_state_change
    end

    state_machine :initial => :booting do
      event :ready do
        transition any => :running_all
      end

      after_transition any => any, :do => :log_state_change
      after_transition :to => :running_all, :do => :run_all_tests
    end

    private

    def run_all_tests
      @strategy.run_all
    end

    def changed!(filename)
      @changed_files << @changed_file = filename
      file_changed
    end

    def reset_changed_files
      @changed_files.clear
    end

    def focused_files_includes_changed_file
      focused_files.include?(changed_file)
    end

    def reset_focuses
      focuses.clear
    end

    def log_state_change
      @strategy.log("Machine entering state: #{state.inspect}")
    end
  end
end
