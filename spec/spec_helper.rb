require 'thor'
require 'ducttape'

def setTestDatabase()
  # Use the test database
  config = Ducttape::Cli::Config.load_config()
  @database = config[:database]
  config[:database] = "database-test"
  Ducttape::Cli::Config.write_config(config)
  # Save database content for later
  @db_content = Ducttape::Cli::Root.load_database()
end

def resetDatabase()
  # Reset database content
  Ducttape::Cli::Root.write_database(@db_content)

  # Change back to previous database used before testing
  config = Ducttape::Cli::Config.load_config()
  config[:database] = @database
  Ducttape::Cli::Config.write_config(config)
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
