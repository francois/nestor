require "test_helper"

context "" do
  setup do
    @mapper = Object.new
    class << @mapper
      def log(*args); end
    end
  end

  context "A new machine" do
    setup { Nestor::Machine.new(@mapper) }
    should("be in the :booting state") { topic.booting? }
  end

  context "A new machine with an :initial_state option" do
    setup { Nestor::Machine.new(@mapper, :quick => true) }
    should("start with the specified state") { topic.green? }
  end
end
