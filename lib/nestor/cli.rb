require "nestor"
require "thor"

module Nestor
  class Cli < Thor # :nodoc:
    default_task :start

    desc("start", <<-EODESC.gsub(/^\s{6}/, ""))
      Starts a continuous test server.

      Specify the framework and test library using --framework and --testlib.
      Valid options are:
        --framework: rails
        --testlib:   test/unit

      Use --quick to boot without running the full test suite on startup.
      --debug writes extra Watchr debug messages to STDOUT.
    EODESC
    method_options :framework => "rails", :testlib => "test/unit", :script => nil, :debug => false, :quick => false
    def start
      Watchr.options.debug = options[:debug]

      if options[:script] then
        puts "Launching with custom script #{options[:script].inspect}"
      else
        puts "Launching..."
      end

      puts "Using #{options[:framework].inspect} framework with #{options[:testlib].inspect} as the testing library"
      mapper      = mapper_instance(options[:framework], options[:testlib])
      machine     = Nestor::Machine.new(mapper, :quick => options[:quick])

      script_path = options[:script] ? Pathname.new(options[:script]) : nil
      script      = Nestor::Script.new(script_path || mapper.class.default_script_path)

      script.nestor_mapper  = mapper
      script.nestor_machine = machine
      Watchr::Controller.new(script, Watchr.handler.new).run
    end

    desc("customize PATH", <<-EODESC.gsub(/^\s{6}/, ""))
      Copies the named script file to PATH to allow customizing.
      Will not overwrite existing files, unless --force is specified.
    EODESC
    method_options :framework => "rails", :testlib => "test/unit", :force => false
    def customize(path)
      raise "Destination #{path.inspect} already exists: will not overwrite" if !options[:force] && File.file?(path)

      puts "Using #{options[:framework].inspect} framework with #{options[:testlib].inspect} as the testing library"
      klass = mapper_class(options[:framework], options[:testlib])
      FileUtils.cp(klass.default_script_path, path)

      puts "Wrote #{klass.name} script to #{path.inspect}"
    end

    private

    def require_path(*paths)
      require "nestor/mappers/#{paths.join("/")}"
    rescue LoadError
      require paths.join("/")
    end

    def mapper_class(framework, testlib)
      require_path(options[:framework], options[:testlib])
      [framework.split("/"), testlib.split("/")].flatten.inject(Nestor::Mappers) do |root, component|
        root.const_get(camelize(component))
      end
    end

    def mapper_instance(framework, testlib)
      mapper_class(framework, testlib).new
    end

    # Copied from ActiveSupport 2.3.4
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
  end
end
