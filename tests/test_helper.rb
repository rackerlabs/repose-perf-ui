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

system "cucumber tests/sinatra/features/index.feature tests/sinatra/features/applications.feature tests/sinatra/features/results.feature tests/sinatra/features/start_stop.feature tests/sinatra/features/repose_plugin_results.feature tests/sinatra/features/load_repose_plugin_results.feature tests/sinatra/features/compare_repose_plugin_results.feature tests/sinatra/features/sysstats_plugin_results.feature tests/sinatra/features/compare_sysstats_plugin_results.feature tests/sinatra/features/load_graphite_plugin_results.feature tests/sinatra/features/graphite_plugin_results.feature tests/sinatra/features/compare_graphite_plugin_results.feature tests/sinatra/features/load_newrelic_plugin_results.feature tests/sinatra/features/newrelic_plugin_results.feature tests/sinatra/features/compare_newrelic_plugin_results.feature tests/sinatra/features/load_jenkins_plugin_results.feature tests/sinatra/features/jenkins_plugin_results.feature tests/sinatra/features/compare_jenkins_plugin_results.feature"

#rest (before/after) then log4j (raw) then diff then email then 
#rest, nagios, postgres, before/afters for graphite, new relic, nagios, postgres
#week after that - 100% code coverage on unit + mongo
#---- PRESENTATION WEEK!!!
#week after that - trends across all tests, emails

#system " tests/sinatra/features/compare_repose_plugin_results.feature tests/sinatra/features/load_sysstats_plugin_results.feature tests/sinatra/features/sysstats_plugin_results.feature"
=begin

- stop actually saves the data 
  - Remote FS Adapter
  - Graphite Adapter
  - New Relic Adapter
  - Log4J Adapter
  - Postgres Adapter
tests/sinatra/features/update_app.feature - this includes updating configs/test/test.json/test_runner.json/requests/response
tests/sinatra/features/rest_plugin.feature
tests/sinatra/features/before_after_plugin_type.feature
tests/sinatra/features/time_series_plugin_type.feature
tests/sinatra/features/slas.feature
tests/sinatra/features/newrelic_plugin.feature
tests/sinatra/features/load_newrelic_plugin.feature
tests/sinatra/features/compare_newrelic_plugin.feature
tests/sinatra/features/graphite_plugin.feature
tests/sinatra/features/load_graphite_plugin.feature
tests/sinatra/features/compare_graphite_plugin.feature
tests/sinatra/features/postgres_plugin.feature
tests/sinatra/features/load_postgres_plugin.feature
tests/sinatra/features/compare_postgres_plugin.feature
tests/sinatra/features/nagios_plugin.feature
tests/sinatra/features/load_nagios_plugin.feature
tests/sinatra/features/compare_nagios_plugin.feature
tests/sinatra/features/log4j_plugin.feature
tests/sinatra/features/load_log4j_plugin.feature
tests/sinatra/features/compare_log4j_plugin.feature
tests/sinatra/features/start_stop_view.feature
tests/sinatra/features/update_app_view.feature
tests/sinatra/features/email.feature
tests/sinatra/features/trends.feature
tests/sinatra/features/diffy.feature
tests/sinatra/features/jmeter.feature
tests/sinatra/features/gatling.feature
tests/sinatra/features/calendar.feature

- add ability to start test running from inside the server 
- add ability to view tests on the fly by hooking directly into disparate sources (not collected though until the test is over)
  - if plugin does not expose the 'read_live_data' method, then the main plugin method will return empty (no error) and will let user know that this plugin is not able to read live data
tests/sinatra/features/flood.feature

- add ability to view results table on click and don't show it on page right away
- add ability to specify server size 

=end
