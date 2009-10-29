require "watchr"
require "nestor/machine"

begin
  require "ruby-debug"
rescue LoadError
  # Ignore: development dependency
end
