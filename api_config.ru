require 'rubygems'
require 'bundler'

Bundler.require

require './api_main.rb'

set :environment, :test

run SnapshotComparer::PerfApp
