require "state_machine"

module Nestor
  # Implements the state machine that is at the heart of Nestor.
  #
  # == Usage
  #
  # In the Watchr script, use +@strategy+ to access an instance of this class.
  #
  # The available events you may call are:
  #
  # <tt>ready!</tt>:: Machine instances start in the +booting+ state.  Once the boot is complete,
  #                   call +ready+ to indicate you are ready to process events.  The default
  #                   rails template calls #ready when +test/test_helper.rb+ is loaded.
  #
  # <tt>changed!</tt>:: Tells the Machine a file changed.  The Watchr script and Strategy are
  #                     responsible for assigning meaning to the file.  The default Watchr
  #                     script knows how to map model, controller and view files to given
  #                     tests, and the script thus only tells the Machine about test files.
  #                     Nothing prevents another implementation from providing the actual
  #                     implementation files and letting the Strategy decide later what to
  #                     do about those.
  #
  # <tt>run_successful!</tt>:: Tells the Machine that the last build was successful.  This
  #                            does not necessarily indicate a a completely green build: only
  #                            that the last run was successful, given the focused files.
  #
  # <tt>run_failed!</tt>:: Tells the Machine there were one or more test failures or errors.
  #                        Again, this doesn't mean the whole build failed: only the last couple
  #                        of files had something that caused a failure.
  #
  # <tt>run!</tt>::  Tells the machine to tell the +#strategy+ to run the tests, given the current
  #                  state of affairs.  This might be running all tests, or a subset if the Machine
  #                  is currently focusing on some items.  A separate event is required by the
  #                  Machine to allow coalescing multiple change events together.
  #
  class Machine
    # The Machine actually delegates running the tests to another object, and this is it's reference.
    attr_reader :strategy      # :nodoc:

    # The list of files we are focusing on, as received by #changed!
    attr_reader :focused_files # :nodoc:

    # The last changed file.  Set by #changed!
    attr_reader :changed_file  # :nodoc:

    # The list of failing tests or examples being focused on right now
    attr_reader :focuses       # :nodoc:

    # +strategy+ is required, and must implement a couple of methods.  See {Nestor::Strategies} for the required calls.
    def initialize(strategy, options={})
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
        transition [:running_all, :running_multi, :running_focused] => same
        transition [:run_focused, :run_focused_pending] => :run_focused_pending, :if => :changed_file_in_focused_files?
        transition [:run_focused_pending, :run_multi_pending, :run_focused] => :run_multi_pending
        transition :green => :run_multi_pending
      end

      event :run do
        transition [:running_all, :running_multi, :running_focused] => same
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

    # Indicates the run was succesful: a green build.  This does not indicate that the
    # whole build was successful: only that the files that ran last were successful.
    def run_successful!(files, tests)
      successful!
    end

    # Indicates there were one or more failures.  +files+ lists the actual files
    # that failed, while +tests+ indicates the test names or examples that failed.
    def run_failed!(files, tests)
      @focused_files, @focuses = files, tests
      failed!
    end

    # Notifies the Machine that a file changed.  This might trigger a state change and schedule a build.
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
