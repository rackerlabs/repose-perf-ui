# Generated by cucumber-sinatra. (2013-08-30 14:13:08 -0500)

ENV['RACK_ENV'] = 'test'
require 'simplecov'
SimpleCov.start

require 'rack/test'
require File.join(File.dirname(__FILE__), '..', '..','..','..', 'main.rb')

require 'capybara'
require 'capybara/cucumber'
#require 'rspec'

Capybara.app = PerfApp

class PerfAppWorld
  include Capybara::DSL
  #include RSpec::Expectations
  #include RSpec::Matchers
  include Rack::Test::Methods
  def app
    @app = Rack::Builder.new do
      run PerfApp
    end
  end
end

World do
  PerfAppWorld.new
end
