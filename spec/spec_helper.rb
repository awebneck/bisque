$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'active_record'
require 'fileutils'
require 'bisque'
require 'pry'

DB_USER = 'bisque'
DB_PASS = 'bisquepass1234'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def stfu
  begin
    orig_stderr = $stderr.clone
    orig_stdout = $stdout.clone
    $stderr.reopen File.new('/dev/null', 'w')
    $stdout.reopen File.new('/dev/null', 'w')
    retval = yield
  rescue Exception => e
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
    raise e
  ensure
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
  end
  retval
end

RSpec.configure do |config|
  dir = File.dirname(__FILE__)
  dbconfig = {
     'host' => '127.0.0.1',
     'adapter' => 'postgresql',
     'encoding' => 'unicode',
     'database' => 'bisque_development',
     'pool' => 5,
     'username' => DB_USER,
     'password' => DB_PASS}

  config.before(:all) do
    ENV["RAILS_ENV"] ||= "test"
    ActiveRecord::Base.establish_connection dbconfig.merge 'database' => 'postgres', 'schema_search_path' => 'public'
    ActiveRecord::Base.connection.create_database dbconfig['database'], dbconfig
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.configurations = {'test' => dbconfig}
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    ActiveRecord::Migration.verbose = false
    stfu do
      load "#{dir}/resources/schema.rb"
      load "#{dir}/resources/models.rb"
    end
  end

  config.after(:all) do
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection dbconfig.merge 'database' => 'postgres', 'schema_search_path' => 'public'
    ActiveRecord::Base.connection.drop_database dbconfig['database']
  end
end
