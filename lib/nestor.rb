require "watchr"
require "nestor/machine"
require "nestor/script"

begin
  require "ruby-debug"
rescue LoadError
  # Ignore: development dependency
end

module Nestor # :nodoc:
end
