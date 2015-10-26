# Repose performance UI

## Technical description

### Technologies used

* Sinatra 
* Redis
* Lighttpd
* Postfix (for email)
* Postgres (planned)

### Application API

* GET /
	* Index page.  Responsible for loading application list from provided configuration file
	* SnapshotComparer::Apps::Bootstrap.application_list (main.rb line 38)
		* Loads all <app name>/bootstrap.rb.  (apps/bootstrap.rb line 49) 
		* Each bootstrap.rb in ctor is responsible for loading its own config file and loading its own view.  The application name comes from directory name (apps/bootstrap.rb line 63).  Currently, we only repose and atom_hopper.
	* Uses index.erb in views/ directory 
* GET /:application
	* Index page for the application.  App name == name loaded from above and loads app_index view with name, desc, title, and app id
	* SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application} (main.rb line 43 to 56)
	* Uses app_index.erb in views/ directory
* GET /:application/applications
	* Load all sub applications for this application.  This is loaded from the config file (see config/apps/repose.yaml for an example)
	* Tests run under each sub application so that we compare apples-to-apples
	* Relevant code in main.rb lines 60 to 69
	* Uses applications.erb in views/ directory
* GET /:application/applications/:name
	* Index page for each sub app (e.g. translation, RBAC, rate limiting, tracing, etc.)
	* name variable must exist in application's config (e.g. for config/apps/repose.yaml the name has to match the id element under sub_apps, such as atom_hopper or identity)
	* request_response_list is a list of Requests and Responses per test.  That's stored in Redis and is loaded from Models/test.rb.
		* The data is stored as lists in "#{application}:#{name}:tests:setup:request_response:request and "#{application}:#{name}:tests:setup:request_response:response (Models/test.rb line 74 and 75)
	* config_list should be removed OR we should have an option to not show this data for public results if we are to use customers' configs
		* Data is stored as list in Redis in "#{application}:#{name}:setup:configs"
		* Each data set is parsed and escaped so that we can properly show it in the UI (Models/configuration.rb line 51)
	* test_location_list shows tests that are loaded PER TEST TYPE.  Also stored in Redis.  Basically you have different tests per test type (load, duration, stress, adhoc, etc.).  This could also be ignored during the refactoring
		* Stored as list in "#{app_name}:#{name}:tests:setup:script"
		* Models/testlocation.rb line 19 	
	* Uses app_detail.erb in views/ directory
* GET /:application/applications/:name/update
	* Meant to update configurations, tests, runners, etc.  Right now is not used.  Could be ignored
	* main.rb line 97
	* NOT RESTFUL :(
* POST /:application/applications/:name/add_request_response
	* Meant to add request/responses to show in the UI.  Could be ignored in refactor.
	* main.rb line 123
	* NOT RESTFUL :(
* POST /:application/applications/:name/update_request_response
	* Meant to update request/responses to show in the UI.  Could be ignored in refactor.
	* main.rb line 157
	* NOT RESTFUL :(
* DELETE /:application/applications/:name/remove_request_response/:requests_to_delete
	* Meant to update request/responses to show in the UI.  Could be ignored in refactor.
	* main.rb line 181
	* NOT RESTFUL :(
* POST /:application/applications/:name/upload_config
	* Meant to upload new configurations.  Could be ignored in refactor.
	* main.rb line 214
	* NOT RESTFUL :(
* POST /:application/applications/:name/upload_test_file
	* Meant to upload new test files (it's a PUT really since it will update the old test per test type).  Could be ignored in refactor.
	* main.rb line 248
	* NOT RESTFUL :(
* POST /:application/applications/:name/remove_config
	* Meant to remove configurations.  Could be ignored in refactor.
	* main.rb line 284
	* NOT RESTFUL :(
* POST /:application/applications/:name/remove_test_file
	* Meant to remove test files.  Could be ignored in refactor.
	* main.rb line 319
	* NOT RESTFUL :(
* GET /:application/applications/:name/test_download/:file_name
	* Meant to download test file.  If we are ignoring the test show, you can ignore this as well (since there's nothing to download)
	* main.rb line 354
	* NOT RESTFUL :(
* GET /:application/results
	* main.rb line 381
	* Shows results for application.
	* For each sub application:
		* load ApplicationTestType and gets overall status (passed or failed)
		* application_test_type.rb line 27
		* gets all results from Redis for each sub app in "#{application}:#{sub_app}:results:status" 
		* iterates through all test results and checks if the App test type is "passed" or "failed" (this is set when app is saved after a test ends)
	* uses results.erb in views/ directory
* GET /:application/results/:name
	* main.rb line 402
	* Loads all test types for this sub application
	* Loads all number of tests for each test type for a specific sub application
		* Basically calculates how many tests ran for each test type for the asked sub application
		* Example, for atom_hopper:
			* 132 load test results
			* 100 stress test results
			* 15 duration test results
			* 50 adhoc results
		* Also loads the status per test type (same logic as above)
		* For each test type (strip _test at the end since the test type key would be 'load' instead of 'load_test')
			* PastSummaryResults ctor (Models/results.rb line 161)
				* initializes results in the bootstrap.rb (apps/bootstrap.rb line 100)
					* this could be either comparison results or singular results
					* comparison results calculates results from 2 tests and subtracts one from the other.  That was to figure out how much footprint repose added over origin
					* singular results calculates results straight forward.  This is used for every other application that doesn't need a comparison feature
					* Each results type has its own summary_view and detailed_view
				* All tests per test type is loaded from Redis (list) "#{application}:#{name}:results:#{test_type}"
					* Iterate through them and retrieve the test guid, app name, sub app name, and test type)
					* We then return all and count (main.rb line 415)
	* Uses results_list.erb from views/ directory				
* GET /:application/results/:name/:test
	* main.rb line 434
	* Loads all test results for a specific test type for a specific sub app for a specific application
	* Loads results from PastSummaryResults (see above)
	* Loads plugin results bootstrap (apps/bootstrap.rb line 139). It loads the available plugins from the congiruation (line 141) and (config/apps/repose.yaml lines 9 to 13)
		* These point to plugin entry files that are responsible for parsing and loading data
		* It uses the summary view loaded from above (depends on whether it's a comparison results or singular results) and sends all data to that .erb
		* For repose it would use views/comparison_summary_results.erb
	* data is loaded from PastSummaryResults.test_results (depends on results type but for repose it will use ComparisonResults.test_results in Models/results.rb line 10) 		
		* It will load all tests
		* For each test:
			* Load meta results (these include configs, request/response, runner (Gatling or Jmeter), test information such as duration, expected throughput, SLAs) (Models/results.rb line 17)
			* Load data results (actual test results and plugin data) (Models/results.rb line 18)
			* Checks both exist
			* Parses test information from meta
			* Loads runner class from bootstrap.rb runner_list (apps/bootstrap.rb line 67)
			* Retrieves summary data location from data results
			* Calls that runner class's compile_summary_results, passing in the test location  
				* Let's use Gatling for our example,  It will load GatlingRunner in models/runner.rb line 204)
				* compile_summary_results will then open the results data file, parse through it and load length, throughput, average, and errors (Models/runner.rb lines 216-235)
			* The returned results are then passed into the Result object.
			* IF IT'S A COMPARISON app type, we are not done.  We then need to load the comparison guid from the test information (meta).  If it doesn't exist, that means the comparison test is still running!  This test is in progress
			* If comparison_guid exists, we load that guid's test result information (Models/results.rb line 31-35) and do a quick math between the results.
			* We load the completed Result object into a temp_list, while deleting the comparison_guid result (so that we don't have duplicates since in Redis they're stored as separate results) - lines 36-48
* GET /:application/results/:name/:test/metric/:metric
	* main.rb line 470
	* Responsible for loading data for every metric (throughput, response time, error rate).
	* Loaded via ajax and is loaded as a json
* GET /:application/results/:name/:test/metric/:metric/id/:id
	* main.rb line 498	
	* Responsible for loading data for every metric (throughput, response time, error rate).
	* Loaded via ajax and is loaded as a json
* GET /:application/results/:name/:test/id/:id
	* main.rb line 526
	* Responsible for load detailed data for a specific test
	* In PastSummaryResults.detailed_results (Models/results.rb line 60)
		* Loads both guids (they're split with + by convention) and loads both result sets
		* Retrieves meta and data results as before but this time calls runner's compile_detailed_results
		* Also loads configuration, request/response, and test location so that way we have specific snapshot of a test
* GET /:application/results/:name/:test/id/:id/plugin/:plugin/:option/find/:criteria
	* main.rb line 564
	* Responsible for loading plugin information based on passed in :plugin id
	* Data is loaded from plugin instance (loaded from above (main.rb line 574) and calls its show_summary_data
		* overloaded per plugin.  An example would be in plugins/repose_jmx_plugin/plugin.rb line 45
		* ability to pass in find criteria (only used in file plugin right now plugins/file_plugin/plugin.rb line 53)
* GET /:application/results/:name/:test/id/:id/plugin/:plugin/:option/:offset/:size
	* main.rb line 609
	* Responsible for a subset of plugin data.  This is used so that we can offset plugin data.  Used mainly in file plugin (see above)
* GET /:application/results/:name/:test/id/:id/plugin/:plugin/:option
	* main.rb line 655
	* Responsible for retrieving plugin data  	 		 
	* Uses plugin's viewer erb template (each plugin has a viewer type as well and is loaded in main.rb line 728 from PluginView)
		* Loaded in Models/plugins/plugin_results.rb line 36
		* Uses the following format "#{plugin_type}_#{application_type}_plugin_results".erb (e.g. views/time_series_comparison_plugin_results.erb)
			* plugin_type = time_series
			* application_type = comparison
			* the plugin type is loaded in each plugin's plugin.rb under show_plugin_names method
	* :option holds the actual plugin while :plugin holds the plugin name.  The example would be:
		* :plugin = sysstats
		* :option = cpu
		* This would then use plugins/sysstats_plugin/plugin.rb line 33-38 that contains the id, name, class that renders data, remote execution (optional for some plugins), and type 		
* GET /:application/results/:name/:test/metric/:metric/compare/:ids
	* main.rb line 757
	* Compares two metrics (these are throughput, response time, error rate)
* GET /:application/results/:name/:test/:id/test_download/:file_name
	* main.rb line 787
	* Downloads specific test execution file for that specific test (Useful for adhoc tests since those do not have specific load test runners stored in application)
* POST /:application/results/:name/:test
    * main.rb line 811
	* Compares multiple tests together.
	* Loads all specified ids in the POST body, loads its data, loads its plugins and renders results
	* Uses results_app_test_compare.erb in views/ directory
* POST /:application/results/:name/:test/compare-plugin/metric
	* main.rb line 850
	* Compares plugin information
	* Ajax response
* POST /:application/results/:name/:test/compare-plugin
	* main.rb line 894
	* Compares plugin information but shows it as a view rendered based on plugin type (same as above)
* All /:application/tests can be ignored.  Those were meant to start/stop tests from UI
* POST /:application/applications/:name/:test/start
	* main.rb line 1141
	* Starts the test!
	* This is called by the test script when it first starts.  It logs the start time in Redis and marks test as started
	* Each call is specific in apps/<app name>/bootstrap.rb start_test_recording
		* For repose it's in apps/bootstrap.rb line 157
		* Calculates current time, generates random guid, stores it as json (line 170)
* POST /:application/applications/:name/:test/stop
	* main.rb line 1167
	* Stops the test!  The main hog!! MAIN REFACTORING POINT!!!!	
	* Calls stop_test_recording in bootstrap.rb line 185
	* Checks for required data and retrieves start timestamp from Redis
	* calls store_data (line 342 in bootstrap.rb)
		* adds guid to Redis (line 344)
		* creates temporary directory for finished test
		* calls copy_meta_data (line 278)
			* retrieves request/response data from meta info for the sub app and puts it into Redis under that guid (line 284)
			* retrieves test script and stores it in /tmp under that guid (line 299)
			* stores script location in redis (line 315)
		* calls copy_meta_test (line 321)
			* retrieves test json info (runner, start, stop, description, name, and comparison guid
			* stores it under the test guid (line 339)
		* retrieves results from the json data that was passed in from the test in the POST (line 361)
		* gets the runner from Redis for this test
		* calls runner.store_results (e.g. would be GatlingRunner.store_results in Models/runner.rb line 275)
			* creates /tmp/guid/data dir (line 282)
			* downloads data to /tmp/guid/data (lines 286-297)
			* store data location in Redis (line 305)
			* compile summary results for this test (line 319)
			* calculates sla (lines 375-400)
		* copies over configs to /tmp (should be removed) (line 369)
		* copies everything from /tmp/guid directory to lighttpd (line 372-394)
	* for each plugin set up for this application
		* call that plugin's store_data method (line 207)
			* example could be sysstats_plugin/plugin.rb line 218
			* validates that the request body has plugins id
			* validates that the request body plugins list contains 'sysstats_plugin'
			* iterates through provided servers (since there could be 1+ target servers)
				* THIS IS SPECIFIC TO SYSSTATS PLUGIN
				* gets the location of the file path
				* uses remote server adapter (line 247) to log onto the server, execute an ssh command (line 259) and upload the resulting data
			
			
			
		 
		  		
		 
