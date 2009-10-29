require "yaml"
require "pathname"
require "test/unit/ui/console/testrunner"

module Nestor
  module Strategies
    module Test
      class Unit
        def initialize(root)
          @root = Pathname.new(root).realpath
        end

        def log(message)
          STDOUT.printf "[%d] %s - %s\n", Process.pid, Time.now.strftime("%H:%M:%S"), message
          STDOUT.flush
        end

        def run_all
          fork do
            log "Run all tests"
            Dir["test/**/*_test.rb"].each {|f| log(f); load f; break}

            ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
            test_runner = ::Nestor::Strategies::Test::TestRunner.new(nil)
            result = ::Test::Unit::AutoRunner.run(false, nil, []) do |autorunner|
              autorunner.runner = lambda { test_runner }
            end

            report(test_runner)
          end
        end

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

            report(test_runner)
          end
        end

        def report(test_runner)
          info = {"status" => test_runner.passed? ? "successful" : "failed", "failures" => {}}
          failures = info["failures"]
          test_runner.faults.each do |failure|
            loc = failure.location.first[1..-1]
            filename = loc.split(":", 2).first
            failures[failure.test_name.split("(", 2).first] = filename
          end

          File.open("tmp/nestor-results.yml", "w") {|io| io.write(info.to_yaml) }
          log "Wrote #{failures.length} failure(s) to tmp/nestor-results.yml"
        end
      end

      class TestRunner < ::Test::Unit::UI::Console::TestRunner
        attr_reader :faults

        def run(suite, output_level=NORMAL)
          @suite = suite.respond_to?(:suite) ? suite.suite : suite
          start
        end

        def passed?
          @faults.empty?
        end
      end
    end
  end
end
