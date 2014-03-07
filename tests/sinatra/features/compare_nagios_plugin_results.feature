Feature: Compare Nagios Plugin Page
	In order to compare tests with nagios plugin data
	As a performance test user
	I want to compare the nagios tests

	Scenario: Compare nagios_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for server_status metrics
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_comparison_app_compare_plugin_results_nagios_plugin_server_status" version
		
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one,key-four,key-two,key-five for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response
	
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+key-three for server_status metrics
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_comparison_app_compare_plugin_results_nagios_plugin_server_status_w_key_three_filters" version
		
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare nagios_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+invalid-key-three for server_status metrics
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_comparison_app_compare_plugin_results_nagios_plugin_server_status" version
		
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one,key-four,invalid-key-three,key-two,key-five for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare nagios_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for server_status metrics
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_comparison_app_compare_plugin_results_nagios_plugin_server_status_only_key_one" version
		
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare nagios_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for unknown metrics
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for NagiosPlugin|||server_status found"
		
	Scenario: Compare nagios_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for unknown metrics graph data
		When I post to "/nagios_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for NagiosPlugin|||server_status found" 

	Scenario: Compare nagios_comparison_app (overhead) main invalid test key-one+key-two for server_status metrics
		When I post to "/nagios_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of nagios_comparison_app/invalid found"
		
	Scenario: Compare nagios_comparison_app (overhead) main invalid test key-one,key-four,key-three,key-two,key-five for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of nagios_comparison_app/invalid found" 
		
	Scenario: Compare nagios_comparison_app (overhead) invalid load test key-one,key-four,key-three,key-two,key-five for server_status metrics graph data
		When I post to "/nagios_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 

	Scenario: Compare invalid main load test key-one and key-two for server_status metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare invalid (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two for server_status metrics
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_singular_app_compare_plugin_results_nagios_plugin_server_status" version
		
	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two for server_status metrics for graph data
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two and key-three for server_status metrics
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And the page should match the "nagios_singular_app_compare_plugin_results_nagios_plugin_w_key_three_filters" version
		
	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two and key-three for server_status metrics for graph data
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two for unknown metrics
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for NagiosPlugin|||unknown found"
		
	Scenario: Compare nagios_singular_app (singular) main load test key-one and key-two for unknown metrics for graph data
		When I post to "/nagios_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "NagiosPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for NagiosPlugin|||unknown found" 

	Scenario: Compare nagios_singular_app (singular) main invalid test key-one and key-two for server_status metrics
		When I post to "/nagios_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of nagios_singular_app/invalid found"
		
	Scenario: Compare nagios_singular_app (singular) main invalid test key-one and key-two for server_status metrics for graph data
		When I post to "/nagios_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of nagios_singular_app/invalid found" 
		
	Scenario: Compare nagios_singular_app (singular) invalid load test key-one and key-two for server_status metrics
		When I post to "/nagios_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No sub application for invalid found"
		
	Scenario: Compare nagios_singular_app (singular) invalid load test key-one and key-two for server_status metrics for graph data
		When I post to "/nagios_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "NagiosPlugin|||server_status"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 		