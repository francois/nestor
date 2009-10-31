require "watchr"
require "pathname"

module Nestor
  module Watchers
    # Knows how to map file change events from Rails conventions to the corresponding test case.
    module Rails
      # Launches a {Watchr::Controller} to and never returns.  The Controller will
      # listen for file change events and trigger appropriate events on the Machine.
      #
      # By default, the Rails watcher will use the +{Nestor::Strategies::Test::Unit}+ strategy.
      #
      # @option options :strategy [Nestor::Strategies] ({Nestor::Strategies::Test::Unit}) The strategy to use.  Must be an instance of a class that implements the protocol defined in {Nestor::Strategies}.
      # @option options :script The path to the Watchr script.
      #
      # @return Never...
      def self.run(options={})
        strategy = options[:strategy] || Nestor::Strategies::Test::Unit.new(Dir.pwd)
        script = instantiate_script(options[:script])

        strategy.log "Instantiating machine"
        script.nestor_strategy = strategy
        script.nestor_machine  = Nestor::Machine.new(strategy)
        Watchr::Controller.new(script, Watchr.handler.new).run
      end

      def self.path_to_script
        default_script_path
      end

      private

      def self.default_script_path
        Pathname.new(File.dirname(__FILE__) + "/rails_script.rb") 
      end

      def self.instantiate_script(path) #:nodoc:
        # Use the default if none provided
        path = default_script_path if path.nil?

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
