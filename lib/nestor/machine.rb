require "state_machine"

module Nestor
  # Implements the state machine that controls Nestor.
  class Machine
    # Machine actually delegates running the tests to another object, and this is it's reference.
    attr_reader :strategy

    # The list of files we are focusing on, as received by #changed!
    attr_reader :focused_files

    # The last changed file.  Set by #changed!
    attr_reader :changed_file

    # The list of tests/specs being focused on right now
    attr_reader :focuses

    def initialize(strategy)
      super() # Have to specify no-args, or else it'll raise an ArgumentError

      @strategy = strategy
      @focused_files, @focuses = [], []

      log_state_change
    end

    state_machine :initial => :booting do
      event :ready do
        transition any => :running_all
      end

      event :failed do
        transition [:running_all, :running_multi, :running_focused] => :run_focused
      end

      event :successful do
        transition :running_focused => :running_multi
        transition :running_multi   => :running_all
        transition :running_all     => :green
      end

      event :file_changed do
        transition [:run_focused, :run_focused_pending] => :run_focused_pending, :if => :changed_file_in_focused_files?
        transition [:run_focused_pending, :run_multi_pending, :run_focused] => :run_multi_pending
        transition :green => :run_multi_pending
      end

      event :run do
        transition :run_focused_pending => :running_focused
        transition :run_multi_pending => :running_multi
      end

      after_transition  any  => any,              :do => :log_state_change
      after_transition  :to  => :running_all,     :do => :run_all_tests
      after_transition  :to  => :running_focused, :do => :run_focused_tests
      after_transition  :to  => :running_multi,   :do => :run_multi_tests
      before_transition :to  => :run_focused,     :do => :log_focus
      before_transition :to  => [:run_focused_pending, :run_multi_pending],
                                                  :do => :log_pending_run
      after_transition  :on  => :file_changed,    :do => :add_changed_file_to_focused_files
    end

    def run_successful!(files, tests)
      successful!
    end

    def run_failed!(files, tests)
      @focused_files, @focuses = files, tests
      failed!
    end

    def changed!(file)
      @changed_file = file
      file_changed!
    end

    private

    def run_all_tests
      reset_focused_files
      reset_focuses
      @strategy.run_all
    end

    def run_multi_tests
      reset_focuses
      @strategy.run(focused_files)
    end

    def run_focused_tests
      @strategy.run(focused_files, focuses)
    end

    def reset_focused_files
      @focused_files.clear
    end

    def add_changed_file_to_focused_files
      @focused_files << @changed_file unless @focused_files.include?(@changed_file)
    end

    def changed_file_in_focused_files?
      @strategy.log("changed_file #{changed_file}, in focused_files? #{focused_files.inspect}")
      focused_files.include?(changed_file)
    end

    def reset_focuses
      focuses.clear
    end

    def log_state_change
      @strategy.log("Machine entering state: #{state.inspect}")
    end

    def log_focus
      @strategy.log("Focusing on #{focuses.inspect}")
    end

    def log_pending_run
      @strategy.log("Run pending...  Waiting for go ahead")
    end
  end
end
