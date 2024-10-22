ENV['RACK_ENV'] = 'test'
require 'simplecov'
require 'rack/test'
require 'rspec'

# Start SimpleCov and configure it
SimpleCov.start do
  enable_coverage :branch  # Enable branch coverage for more detailed insights
  add_filter "/spec/"       # Exclude the 'spec' directory from coverage results
end

require File.expand_path '../../app.rb', __FILE__  # Adjust to the path of your main app file

RSpec.configure do |config|
  config.include Rack::Test::Methods  # Include rack-test for Sinatra integration tests

  # Define the app method that returns your Sinatra application instance
  def app
    Sinatra::Application  # If modular, replace with your app class name
  end

end
