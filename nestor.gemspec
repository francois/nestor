# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nestor}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2009-11-17}
  s.default_executable = %q{nestor}
  s.description = %q{Nestor watches file system events and responds by running the tests or specs that match the changed files.}
  s.email = %q{francois@teksol.info}
  s.executables = ["nestor"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "bin/nestor",
     "doc/.gitignore",
     "doc/state-diagram.graffle",
     "doc/state-diagram.png",
     "lib/nestor.rb",
     "lib/nestor/cli.rb",
     "lib/nestor/machine.rb",
     "lib/nestor/mappers.rb",
     "lib/nestor/mappers/rails/test/rails_test_unit.rb",
     "lib/nestor/mappers/rails/test/unit.rb",
     "lib/nestor/script.rb",
     "nestor.gemspec",
     "test/machine_test.rb",
     "test/rails_mapper_test.rb",
     "test/riot_macros/map.rb",
     "test/script_test.rb",
     "test/test_helper.rb",
     "vendor/watchr-0.5.7/.gitignore",
     "vendor/watchr-0.5.7/History.txt",
     "vendor/watchr-0.5.7/LICENSE",
     "vendor/watchr-0.5.7/Manifest",
     "vendor/watchr-0.5.7/README.rdoc",
     "vendor/watchr-0.5.7/Rakefile",
     "vendor/watchr-0.5.7/TODO.txt",
     "vendor/watchr-0.5.7/bin/watchr",
     "vendor/watchr-0.5.7/docs.watchr",
     "vendor/watchr-0.5.7/gem.watchr",
     "vendor/watchr-0.5.7/lib/watchr.rb",
     "vendor/watchr-0.5.7/lib/watchr/controller.rb",
     "vendor/watchr-0.5.7/lib/watchr/event_handlers/base.rb",
     "vendor/watchr-0.5.7/lib/watchr/event_handlers/portable.rb",
     "vendor/watchr-0.5.7/lib/watchr/event_handlers/unix.rb",
     "vendor/watchr-0.5.7/lib/watchr/script.rb",
     "vendor/watchr-0.5.7/manifest.watchr",
     "vendor/watchr-0.5.7/specs.watchr",
     "vendor/watchr-0.5.7/test/README",
     "vendor/watchr-0.5.7/test/event_handlers/test_base.rb",
     "vendor/watchr-0.5.7/test/event_handlers/test_portable.rb",
     "vendor/watchr-0.5.7/test/event_handlers/test_unix.rb",
     "vendor/watchr-0.5.7/test/test_controller.rb",
     "vendor/watchr-0.5.7/test/test_helper.rb",
     "vendor/watchr-0.5.7/test/test_script.rb",
     "vendor/watchr-0.5.7/test/test_watchr.rb",
     "vendor/watchr-0.5.7/watchr.gemspec"
  ]
  s.homepage = %q{http://github.com/francois/nestor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "vendor/watchr-0.5.7/lib", "vendor/watchr-0.5.7/lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Nestor keeps the place tidy by running your specs/tests everytime a file changes}
  s.test_files = [
    "test/machine_test.rb",
     "test/rails_mapper_test.rb",
     "test/riot_macros/map.rb",
     "test/script_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>, [">= 0.2.3.5"])
      s.add_development_dependency(%q<riot>, [">= 0.9.12"])
      s.add_runtime_dependency(%q<state_machine>, [">= 0.8.0"])
      s.add_runtime_dependency(%q<thor>, [">= 0.11.6"])
    else
      s.add_dependency(%q<yard>, [">= 0.2.3.5"])
      s.add_dependency(%q<riot>, [">= 0.9.12"])
      s.add_dependency(%q<state_machine>, [">= 0.8.0"])
      s.add_dependency(%q<thor>, [">= 0.11.6"])
    end
  else
    s.add_dependency(%q<yard>, [">= 0.2.3.5"])
    s.add_dependency(%q<riot>, [">= 0.9.12"])
    s.add_dependency(%q<state_machine>, [">= 0.8.0"])
    s.add_dependency(%q<thor>, [">= 0.11.6"])
  end
end

