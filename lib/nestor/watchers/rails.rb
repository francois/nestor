require "watchr"
require "pathname"

module Nestor
  module Watchers
    # Implements the Test::Unit based backend on a plain-jane Rails install.
    module Rails
      # This method never returns
      def self.run(strategy = Nestor::Strategies::Test::Unit.new(Dir.pwd))
        script = instantiate_script

        strategy.log "Instantiating machine"
        script.nestor_strategy = strategy
        script.nestor_machine  = Nestor::Machine.new(strategy)
        Watchr::Controller.new(script, Watchr.handler.new).run
      end

      def self.instantiate_script #:nodoc:
        script = Watchr::Script.new(Pathname.new(File.dirname(__FILE__) + "/rails_script.rb"))
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
