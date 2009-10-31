def log(message) #:nodoc:
  @strategy.log(message)
end

RAILS_ENV = "test" unless defined?(RAILS_ENV)
log "Entering #{RAILS_ENV.inspect} environment"

log "Creating tmp/ if it doesn't exist"
Dir.mkdir("tmp") unless File.directory?("tmp")

log "Preloading test/test_helper.rb"
start_load_at = Time.now
$LOAD_PATH.unshift "test" unless $LOAD_PATH.include?("test")
require "test_helper"

end_load_at = Time.now
log "Waiting for changes (saving #{end_load_at - start_load_at} seconds per run)..."

def sendoff(timeout=0.8, path="tmp/nestor-sendoff") #:nodoc:
  Thread.start(timeout, path) do |timeout, path|
    log "Sendoff pending #{timeout}..."
    sleep timeout
    File.open(path, "w") {|io| io.write(rand.to_s)}
    log "Sendoff fired on #{path}"
  end
end

def changed!(filename) #:nodoc:
  @machine.changed! filename
  sendoff
end

watch 'app/models/(.+)\.rb' do |md|
  test_file = "test/unit/#{md[1]}_test.rb"
  log "#{md[0].inspect} => #{test_file.inspect}"
  changed! test_file if File.file?(test_file)
end

watch 'app/controllers/(.+)\.rb' do |md|
  test_file = "test/functional/#{md[1]}_test.rb"
  log "#{md[0].inspect} => #{test_file.inspect}"
  changed! test_file if File.file?(test_file)
end

# It might be possible to run focused tests with the view name
watch 'app/views/(.+)' do |md|
  segments = md[1].split("/")
  path     = segments[0..-2]
  test_file = "test/functional/#{path.join("/")}_controller_test.rb"
  log "#{md[0].inspect} => #{test_file.inspect}"
  changed! test_file if File.file?(test_file)
end

watch 'config/' do |md|
  @machine.reset!
end

watch 'test/test_helper\.rb' do |md|
  @machine.reset!
end

watch 'db/schema.rb' do |_|
  log "Detected changed schema: preparing test DB"
  system("rake db:test:prepare")
end

watch 'test/(?:unit|functional|integration|performance)/.*' do |md|
  log "#{md[0].inspect} => #{md[0].inspect}"
  changed! md[0]
end

watch 'tmp/nestor-results.yml' do |md|
  # Since we received the results, we must receive our child process' status, or
  # else we'll have zombie processes lying around
  Thread.start { Process.wait }

  info = YAML.load_file(md[0])
  log "New results in: #{info.inspect}"
  failures = info["failures"]
  @machine.send("run_#{info["status"]}!", failures.values.flatten.uniq, failures.keys)
end

watch 'tmp/nestor-sendoff' do |_|
  log "Sendoff"
  @machine.run!
end

@machine.ready!
