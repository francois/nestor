require "yaml"
require "pathname"

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

            require "test/unit/autorunner"
            result = ::Test::Unit::AutoRunner.run(false, nil, []) do |runner|
            end

            log "Tests have ran: passed? #{result.inspect}"
          end
        end

        def run(test_files, focuses=[])
          if focuses.empty? then
            log "Running multi: #{test_files.inspect}"
          else
            log "Running focused tests on #{test_files.inspect}: #{focuses.inspect}"
          end
        end
      end
    end
  end
end
