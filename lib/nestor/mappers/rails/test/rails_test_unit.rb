def log(message) #:nodoc:
  @machine.log(message)
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
    log "Sendoff pending in #{timeout}s..."
    sleep timeout
    File.open(path, "w") {|io| io.write(rand.to_s)}
    log "Sendoff fired on #{path}"
  end
end

def changed!(filename) #:nodoc:
  return if File.directory?(filename)
  @machine.changed! filename
  sendoff
end

watch 'config/(?:.+)\.(?:rb|ya?ml)' do |md|
  changed! md[0]
end

watch '(?:app|test)/.+\.rb' do |md|
  changed! md[0]
end

watch 'app/views/.+' do |md|
  changed! md[0]
end

watch 'db/schema.rb' do |md|
  log "Detected changed schema: preparing test DB"
  system("rake db:test:prepare")
  changed! md[0]
end

# This is only to trigger the tests after a slight delay, but from the main thread.
watch 'tmp/nestor-sendoff' do |_|
  log "Sendoff"
  @machine.run!
end

@machine.ready!
