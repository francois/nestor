require "yaml"
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
        fork do
          log "Run all tests"
          test_files = Dir["test/**/*_test.rb"]
          test_files.each {|f| log(f); load f}

          ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
          test_runner = ::Nestor::Strategies::Test::TestRunner.new(nil)
          result = ::Test::Unit::AutoRunner.run(false, nil, []) do |autorunner|
            autorunner.runner = lambda { test_runner }
          end

          report(test_runner, test_files)
        end
      end

      # Runs only the named files, and optionally focuses on only a couple of tests
      # within the loaded test cases.
      def run(test_files, focuses=[])
        fork do
          log "Running #{focuses.length} focused tests"
          test_files.each {|f| log(f); load f}

          ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
          test_runner = ::Nestor::Strategies::Test::TestRunner.new(nil)
          result = ::Test::Unit::AutoRunner.run(false, nil, []) do |autorunner|
            autorunner.runner = lambda { test_runner }
            autorunner.filters << proc{|t| focuses.include?(t.method_name)} unless focuses.empty?
          end

          report(test_runner, test_files)
        end
      end

      def map(path)
        case path
        when %r{^app/.+/(.+_observer)\.rb$} # Has to be first, or app/models might kick in first
          orig, plain  = $1, $1.sub("_observer", "")
          ["test/unit/#{orig}_test.rb", "test/unit/#{plain}_test.rb"]
        when %r{^app/models/(.+)\.rb$}, %r{^lib/(.+)\.rb$}
          ["test/unit/#{$1}_test.rb"]
        when %r{^app/controllers/(.+)\.rb$}
          ["test/functional/#{$1}_test.rb"]
        when %r{^app/views/(.+)/(.+)\.\w+$}
          ["test/functional/#{$1}_controller_test.rb"]
        else
          Array(path)
        end
      end

      private

      # Since we forked, we can't call into the Machine from the child process.  Upstream
      # communications is implemented by writing new files to the filesystem and letting
      # the parent process catch the changes.
      def report(test_runner, test_files)
        info = {"status" => test_runner.passed? ? "successful" : "failed", "failures" => {}}
        failures = info["failures"]
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

        File.open("tmp/nestor-results.yml", "w") {|io| io.write(info.to_yaml) }
        log "Wrote #{failures.length} failure(s) to tmp/nestor-results.yml"
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
