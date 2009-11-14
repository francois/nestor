require "yaml"
require "slave"
require "pathname"
require "test/unit/ui/console/testrunner"

# Just declare the module to prevent deeply nested code below
module Nestor
  module Mappers
    module Rails
    end
  end
end

module Nestor::Mappers::Rails
  module Test
    class Unit
      # Returns the path to the script this {Mapper} uses.
      def self.default_script_path
        Pathname.new(File.dirname(__FILE__) + "/rails_test_unit.rb")
      end

      # Utility method to extract data from a Test::Unit failure.
      #
      # @param failure [Test::Unit::Failure, Test::Unit::Error] The Test::Unit failure or error from which to extract information.
      # @param test_files [Array<String>] The list of files that might have generated this failure.  This is used to detect the file that caused the failure.
      #
      # @return [String, String] Returns the filename and test name as a 2 element Array.
      def self.parse_failure(failure, test_files)
        filename = if failure.respond_to?(:location) then
                     failure.location.map do |loc|
                       filename = loc.split(":", 2).first
                       test_files.detect {|tf| filename.include?(tf)}
                     end.compact.first
                   elsif failure.respond_to?(:exception) then
                     failure.exception.backtrace.map do |loc|
                       filename = loc.split(":", 2).first
                       loc = loc[1..-1] if loc[0,1] == "/"
                       test_files.detect {|tf| filename.include?(tf)}
                     end.compact.first
                   else
                     raise "Unknown object type received as failure: #{failure.inspect} doesn't have #exception or #location methods."
                   end

        test_name = failure.test_name.split("(", 2).first.strip.sub(/\.$/, "")

        [filename, test_name]
      end

      # Logs a message to STDOUT.  This implementation forks, so the #log method also
      # provides the PID of the logger.
      def log(message)
        STDOUT.printf "[%d] %s - %s\n", Process.pid, Time.now.strftime("%H:%M:%S"), message
        STDOUT.flush
      end

      # Runs absolutely all tests as found by walking test/.
      def run_all
        IO.popen("-") do |pipe|
          return receive_results(pipe) if pipe
          setup_lifeline

          log "Run all tests"
          test_files = load_test_files(["test"])

          ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
          test_runner = ::Nestor::Mappers::Rails::Test::TestRunner.new(nil)
          result = ::Test::Unit::AutoRunner.run(false, nil, []) do |autorunner|
            autorunner.runner = lambda { test_runner }
          end

          # Returns a Hash which the parent process will retrieve
          report(test_runner, test_files)
        end
      end

      # Runs only the named files, and optionally focuses on only a couple of tests
      # within the loaded test cases.
      def run(test_files, focuses=[])
        log "Running #{test_files.inspect} focusing on #{focuses.inspect}"
        IO.popen("-") do |pipe|
          return receive_results(pipe) if pipe
          setup_lifeline

          log "Running #{focuses.length} focused tests"
          load_test_files(test_files)

          ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
          test_runner = ::Nestor::Mappers::Rails::Test::TestRunner.new(nil)
          result = ::Test::Unit::AutoRunner.run(false, nil, []) do |autorunner|
            autorunner.runner = lambda { test_runner }
            autorunner.filters << proc{|t| focuses.include?(t.method_name)} unless focuses.empty?
          end

          # Returns a Hash the parent process will retrieve
          report(test_runner, test_files)
        end
      end

      # Given a path, returns an Array of strings for the tests that should be run.
      #
      # This implementation maps +app/models+ to +test/unit+, +app/controllers+ and +app/views+ to +test/functional+.
      # It is not the responsibility of #map to determine if the files actually exist on disk.  The {Nestor::Machine}
      # will verify the files exist before attempting to run them.
      #
      #
      # @example
      # 
      #   mapper = Nestor::Mappers::Rails::Test::Unit.new
      #   mapper.map("app/models/user.rb")
      #   #=> ["test/unit/user_test.rb"]
      #   mapper.map("app/helpers/users_helper.rb")
      #   #=> ["test/unit/helpers/users_helper.rb", "test/functional/users_controller_test.rb"]
      #
      #   # Mapper is saying to re-run all functional tests
      #   mapper.map("app/controller/application_controller.rb")
      #   #=> ["test/functional/"]
      #
      #   # Mapper is saying to run all tests
      #   mapper.map("config/environment.rb")
      #   #=> []
      #
      # @param path [String] A relative path to a file in the project.
      # @return [Array<String>, nil] One or more paths the {Nestor::Machine} should run in response to the change.
      #   It is entirely possible and appropriate that this method return an empty array, which implies to run
      #   all tests.  If a path points to a directory, this implies running all tests under that directory.
      #   Returning +nil+ implies no tests need to run (such as when editing a README).
      def map(path)
        case path
        when %r{^app/.+/(.+_observer)\.rb$}              # Has to be first, or app/models might kick in first
          orig, plain  = $1, $1.sub("_observer", "")
          ["test/unit/#{orig}_test.rb", "test/unit/#{plain}_test.rb"]

        when "app/controllers/application_controller.rb" # Again, special cases first
          ["test/functional/"]

        when "app/helpers/application_helper.rb"         # Again, special cases first
          ["test/unit/helpers/", "test/functional/"]

        when %r{^app/models/(.+)\.rb$}, %r{^lib/(.+)\.rb$}
          ["test/unit/#{$1}_test.rb"]

        when %r{^app/controllers/(.+)\.rb$}
          ["test/functional/#{$1}_test.rb"]

        when %r{^app/views/(.+)/(.+)\.\w+$}
          ["test/functional/#{$1}_controller_test.rb"]

        when %r{^app/helpers/(.+)_helper\.rb$}
          ["test/unit/helpers/#{$1}_helper_test.rb", "test/functional/#{$1}_controller_test.rb"]

        when %r{^(?:test/test_helper.rb|config/.+\.(?:rb|ya?ml|xml)|db/schema\.rb)$}
          # Rerun all tests because something fundamental changed
          []

        when %r{^test/.+_test.rb}
          # Rerun the sole test when it's a test
          Array(path)

        else
          # I don't know how to map this, so it's probably a README or something
          nil
        end
      end

      private

      def setup_lifeline
        ppid = Process.ppid
        log "Setting up lifeline on #{Process.pid} for #{Process.ppid}"

        Thread.start do
          sleep 0.5
          next if ppid == Process.ppid

          # Parent must have died because we don't have the same parent PID
          # Die ourselves
          log "Dying because parent changed"
          exit!
        end
      end

      def receive_results(pipe)
        data = YAML.load(pipe.read)
        Process.wait # Ensure no zombie processes
        data
      end

      def load_test_files(test_files)
        test_files.inject([]) do |memo, f|
          case
          when File.directory?(f)
            Dir["#{f}/**/*_test.rb"].each do |f1|
              log(f1)
              load f1
              memo << f1
            end
          when File.file?(f)
            log(f)
            load f
            memo << f
          else
            # Ignore
          end

          memo
        end
      end

      # Print to STDOUT the results of the run.  The parent's listening on the pipe to get the data.
      def report(test_runner, test_files)
        info = {:passed => test_runner.passed?, :failures => {}}
        failures = info[:failures]
        test_runner.faults.each do |failure|
          filename, test_name = self.class.parse_failure(failure, test_files)
          if filename.nil? then
            log("Could not map #{failure.test_name.inspect} to a specific test file: mapping to #{test_files.length} files")
            failures[test_name] = test_files
          else
            log("Failed #{failure.test_name.inspect} in #{filename.inspect}")
            failures[test_name] = filename
          end
        end

        puts info.to_yaml
      end
    end

    # A helper class that allows me to get more information from the build.
    #
    # This is something that definitely will change when Nestor is tested on Ruby 1.9.
    class TestRunner < ::Test::Unit::UI::Console::TestRunner #:nodoc:
      attr_reader :faults

      # This is a duck-typing method.  Test::Unit's design requiers a #run method,
      # but it is implemented as a class method.  I fake it here to allow me to
      # pass an instance and have the actual TestRunner instance available afterwards.
      def run(suite, output_level=NORMAL)
        @suite = suite.respond_to?(:suite) ? suite.suite : suite
        start
      end

      # Returns pass/fail status.
      def passed?
        @faults.empty?
      end
    end
  end
end
