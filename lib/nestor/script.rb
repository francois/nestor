module Nestor
  class Script < Watchr::Script
    # Let the script have a reference to the mapper, to generate events.
    # The actual instance variable name is +@mapper+, not +@nestor_mapper+.
    def nestor_mapper=(mapper)
      @mapper = mapper
    end
  end
end
