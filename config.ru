require 'rubygems' 
require 'bundler'  

Bundler.require  

require './main.rb'

set :environment, :test
 
run PerfApp
