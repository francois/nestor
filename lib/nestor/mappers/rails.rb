module Nestor
  module Mappers
    class Rails
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
    end
  end
end
