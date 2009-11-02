module Nestor
  class Script < Watchr::Script
    # Let's the script have a reference to the machine, to generate events.
    # The actual instance variable name is +@machine+, not +@nestor_machine+.
    def nestor_machine=(machine)
      @machine = machine
    end
  end
end
