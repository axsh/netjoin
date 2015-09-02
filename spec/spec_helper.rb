require 'thor'
require 'netjoin'

def setTestDatabase()
  # Use the test database
  config = Netjoin::Cli::Config.load_config()
  @database = config[:database]
  config[:database] = "database-test"
  Netjoin::Cli::Config.write_config(config)
  # Save database content for later
  @db_content = Netjoin::Cli::Root.load_database()
end

def resetDatabase()
  # Reset database content
  Netjoin::Cli::Root.write_database(@db_content)

  # Change back to previous database used before testing
  config = Netjoin::Cli::Config.load_config()
  config[:database] = @database
  Netjoin::Cli::Config.write_config(config)
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
  File.delete('test.yml') if File.exist?('test.yml')
}}
