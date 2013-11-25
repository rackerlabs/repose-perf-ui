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

system "cucumber tests/sinatra/features/index.feature tests/sinatra/features/applications.feature tests/sinatra/features/results.feature"
=begin
system "cucumber tests/sinatra/features/repose_plugin.feature tests/sinatra/features/newrelic_plugin.feature tests/sinatra/features/graphite_plugin.feature"
system "cucumber tests/sinatra/features/sysstats_plugin.feature tests/sinatra/features/postgres_plugin.feature tests/sinatra/features/nagios_plugin.feature"
system "cucumber tests/sinatra/features/log4j_plugin.feature"
system "cucumber tests/sinatra/features/start_stop.feature"
=end
=begin
- add ability to view logs
- add server stats to results
- add ability to view results table on click and don't show it on page right away
- add ability to view when the test will start and when the test will end
- add ability to start test (not while something else is running)
- add ability to start test running from inside the server 
- add ability to specify server size 
- add test type for flood and autobench
=end
