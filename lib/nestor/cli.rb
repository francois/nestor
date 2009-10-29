require "nestor"
require "thor"

module Nestor
  class Cli < Thor
    desc("start", <<-EODESC.gsub(/^\s{6}/, ""))
    EODESC
    method_options :strategy => "test/unit", :watcher => "rails", :script => "", :debug => false, :include => []
    def start
      puts "Using #{options[:strategy].inspect} strategy"
      require "nestor/strategies/#{options[:strategy]}"

      puts "Using #{options[:watcher].inspect} watcher"
      require "nestor/watchers/#{options[:watcher]}"

      Watchr.options.debug = options[:debug]

      puts "Launching..."
      Nestor::Watchers::Rails.run
    end
  end
end
