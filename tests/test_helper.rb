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
TODO: load up jmx metric data for repose plugin and finish repose_plugin.feature.
TODO: start working with the start and stop
- start will create new guid but will also have name, length, comparison_guid (opt)
- stop actually saves the data 
  - Remote FS Adapter
  - Graphite Adapter
  - New Relic Adapter
  - Log4J Adapter
  - Postgres Adapter
system "cucumber tests/sinatra/features/repose_plugin.feature tests/sinatra/features/newrelic_plugin.feature tests/sinatra/features/graphite_plugin.feature"
system "cucumber tests/sinatra/features/sysstats_plugin.feature tests/sinatra/features/postgres_plugin.feature tests/sinatra/features/nagios_plugin.feature"
system "cucumber tests/sinatra/features/log4j_plugin.feature"
system "cucumber tests/sinatra/features/start_stop.feature"
=end
=begin
- add ability to compare by plugins
- add ability to view logs
- add server stats to results
- add ability to view results table on click and don't show it on page right away
- add ability to view when the test will start and when the test will end
- add ability to start test (not while something else is running) and stop it
- add ability to start test running from inside the server 
- add ability to specify server size 
- add test type for flood and autobench
- add ability to view tests on the fly but hooking directly into disparate sources (not collected though until the test is over)
  - if plugin does not expose the 'read_live_data' method, then the main plugin method will return empty (no error) and will let user know that this plugin is not able to read live data
=end
