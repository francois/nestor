require "nestor"
require "thor"

module Nestor
  class Cli < Thor # :nodoc:
    desc("start", <<-EODESC.gsub(/^\s{6}/, ""))
      Starts a continuous test server.
    EODESC
    method_options :strategy => "test/unit", :watcher => "rails", :script => nil, :debug => false, :include => []
    def start
      puts "Using #{options[:strategy].inspect} strategy"
      begin
        # Try the internal version
        require "nestor/strategies/#{options[:strategy]}"
      rescue LoadError
        # Else fallback to something I'm not aware of right now
        require options[:strategy]
      end

      puts "Using #{options[:watcher].inspect} watcher"
      begin
        require "nestor/watchers/#{options[:watcher]}"
      rescue LoadError
        # Fallback to something external again
        require options[:watcher]
      end

      Watchr.options.debug = options[:debug]

      if options[:script] then
        puts "Launching with custom script #{options[:script].inspect}"
      else
        puts "Launching..."
      end
      Nestor::Watchers::Rails.run(:script => options[:script] ? Pathname.new(options[:script]) : nil)
    end

    desc("customize PATH", <<-EODESC.gsub(/^\s{6}/, ""))
      Copies the named script file to PATH to allow customizing.
    EODESC
    method_options :strategy => "test/unit", :watcher => "rails"
    def customize(path)
      puts "Using #{options[:watcher].inspect} watcher"
      require "nestor/watchers/#{options[:watcher]}"

      raise "Destination #{path.inspect} already exists: will not overwrite" if File.file?(path)
      FileUtils.cp(Nestor::Watchers::Rails.path_to_script, path)

      puts "Wrote #{options[:watcher]} script to #{path.inspect}"
    end
  end
end
