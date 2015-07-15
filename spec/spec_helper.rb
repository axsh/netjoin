require 'thor'
require 'ducttape'
require 'ducttapeCLI'

def setTestDatabase()
  # Use the test database
  config = DucttapeCLI::Config.loadConfig()
  @database = config[:database]   
  config[:database] = "database-test"
  DucttapeCLI::Config.writeConfig(config)
  # Save database content for later
  @db_content = DucttapeCLI::CLI.loadDatabase()
end

def resetDatabase()
  # Reset database content
  DucttapeCLI::CLI.writeDatabase(@db_content)
    
  # Change back to previous database used before testing
  config = DucttapeCLI::Config.loadConfig()
  config[:database] = @database
  DucttapeCLI::Config.writeConfig(config)
end

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end

  result
end

RSpec.configure {|c| c.before(:all) {
  setTestDatabase()
}}

RSpec.configure {|c| c.after(:all) {
  resetDatabase()
}}
