require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "nestor"
    gem.summary = %Q{Nestor keeps the place tidy by running your specs/tests everytime a file changes}
    gem.description = %Q{Nestor watches file system events and responds by running the tests or specs that match the changed files.}
    gem.email = "francois@teksol.info"
    gem.homepage = "http://github.com/francois/nestor"
    gem.authors = ["François Beausoleil"]
    gem.add_development_dependency "yard", ">= 0.2.3.5"
    gem.add_development_dependency "riot", ">= 0.9.12"
    FileList["vendor/*/lib"].each do |lib|
      gem.require_paths << lib
    end

    # For now, I need a vendored watchr version
    # gem.add_dependency "watchr", ">= 0.5.7"
    gem.add_dependency "state_machine", ">= 0.8.0"
    gem.add_dependency "thor", ">= 0.11.6"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :release => "gemcutter:release"

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  Dir["vendor/*/lib"].each {|lib| t.libs << lib}
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

task :test => :check_dependencies

begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

namespace :state_machine do
  task :draw do
    $:.unshift(File.dirname(__FILE__) + "/lib")
    require "state_machine"
    require "nestor/machine"
    StateMachine::Machine.draw("Nestor::Machine", {})
  end
end
