require "watchr"
require "pathname"

module Nestor
  module Watchers
    # Knows how to map file change events from Rails conventions to the corresponding test case.
    module Rails
      # Launches a Watchr::Controller to and never returns.  The Controller will
      # listen for file change events and trigger appropriate events on the Machine.
      #
      # By default, the Rails watcher will use the +Test::Unit+ strategy.
      #
      # @option :strategy The strategy to use.
      # @option :script The path to the Watchr script.
      #
      # @return Never...
      def self.run(options={})
        options[:strategy] = Nestor::Strategies::Test::Unit.new(Dir.pwd) if options[:strategy].nil?
        script = instantiate_script(options[:script])

        strategy.log "Instantiating machine"
        script.nestor_strategy = strategy
        script.nestor_machine  = Nestor::Machine.new(strategy)
        Watchr::Controller.new(script, Watchr.handler.new).run
      end

      private

      def self.instantiate_script(path) #:nodoc:
        # Use the default if none provided
        path = Pathname.new(File.dirname(__FILE__) + "/rails_script.rb") if path.nil?

        script = Watchr::Script.new(path)
        class << script
          def nestor_machine=(m)
            @machine = m
          end

          def nestor_strategy=(s)
            @strategy = s
          end
        end

        script
      end
    end
  end
end
