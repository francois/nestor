module Nestor
  module Test
    module Macros
      def should_map(params)
        params.each_pair do |key, values|
          asserts(key.inspect) { topic.map(key) }.equals(values)
        end
      end
    end
  end
end

Riot::Context.instance_eval { include Nestor::Test::Macros }
