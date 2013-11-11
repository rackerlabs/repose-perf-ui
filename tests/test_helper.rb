require 'simplecov'

SimpleCov.start

require 'test/unit'
require 'yaml'
require 'mocha/setup'
=begin
require './tests/Models/jmx_results_test.rb'
require './tests/Models/summary_results_test.rb'
require './tests/Models/live_summary_results_test.rb'
require './tests/Models/configuration_tests.rb'
require './tests/Models/application_tests.rb'
require './tests/Models/database_tests.rb'
require './tests/Models/perftest_tests.rb'
require './tests/Models/request_tests.rb'
require './tests/Models/response_tests.rb'
require './tests/Models/test_tests.rb'
require './tests/Models/testlocation_tests.rb'
=end

system "cucumber tests/sinatra/features/index.feature tests/sinatra/features/applications.feature" # tests/sinatra/features/results.feature"
=begin
system "cucumber tests/sinatra/features/tests.feature tests/sinatra/features/results.feature tests/sinatra/features/jmx_results.feature"
system "cucumber tests/sinatra/features/network_results.feature"
=end
=begin
- add ability to view logs
- add server stats to results
- add ability to view results table on click and don't show it on page right away
- add ability to view when the test will start and when the test will end
- add ability to start test (not while something else is running)
- add ability to start test running from inside the server 
- add ability to specify server size 
=end