require "nestor"
require "thor"

module Nestor
  class Cli < Thor # :nodoc:
    default_task :start

    desc("start", <<-EODESC.gsub(/^\s{6}/, ""))
      Starts a continuous test server.
    EODESC
    method_options :framework => "rails", :testlib => "test/unit", :script => nil, :debug => false, :include => []
    def start
      puts "Using #{options[:framework].inspect} framework with #{options[:testlib].inspect} as the testing library"
      require_path(options[:framework], options[:testlib])

      Watchr.options.debug = options[:debug]

      if options[:script] then
        puts "Launching with custom script #{options[:script].inspect}"
      else
        puts "Launching..."
      end

      mapper_class(options[:framework], options[:testlib]).run(:script => options[:script] ? Pathname.new(options[:script]) : nil)
    end

    desc("customize PATH", <<-EODESC.gsub(/^\s{6}/, ""))
      Copies the named script file to PATH to allow customizing.
    EODESC
    method_options :strategy => "test/unit", :watcher => "rails"
    def customize(path)
      puts "Using #{options[:framework].inspect} framework with #{options[:testlib].inspect} as the testing library"
      require_path(options[:framework], options[:testlib])

      raise "Destination #{path.inspect} already exists: will not overwrite" if File.file?(path)
      FileUtils.cp(Nestor::Watchers::Rails.path_to_script, path)

      puts "Wrote #{options[:watcher]} script to #{path.inspect}"
    end

    private

    def require_path(*paths)
      require "nestor/mappers/#{paths.join("/")}"
    rescue LoadError
      require paths.join("/")
    end

    def mapper_class(framework, testlib)
      [framework.split("/"), testlib.split("/")].flatten.inject(Nestor::Mappers) do |root, component|
        root.const_get(camelize(component))
      end
    end

    # Copied from ActiveSupport 2.3.4
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true) #:nodoc:
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
  end
end
