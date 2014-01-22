Feature: Compare Graphite Plugin Page
	In order to compare tests with graphite plugin data
	As a performance test user
	I want to compare the graphite tests

	Scenario: Compare graphite_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for memory metrics
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "37695556.266666666"
		And the message should contain "10.827373335820106"
		And the message should contain "carbon.agents.graphite-a.memUsage"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "instance"
		
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one,key-four,key-two,key-five for memory metrics graph data
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response
	
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+key-three for memory metrics
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-three"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "37695556.266666666"
		And the message should contain "10.827373335820106"
		And the message should contain "38080716.8"
		And the message should contain "11.075134201771649"
		And the message should contain "carbon.agents.graphite-a.memUsage"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "instance"
		
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare graphite_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+invalid-key-three for memory metrics
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "37695556.266666666"
		And the message should contain "10.827373335820106"
		And the message should contain "carbon.agents.graphite-a.memUsage"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "instance"
		
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one,key-four,invalid-key-three,key-two,key-five for memory metrics graph data
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare graphite_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for memory metrics
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "10.827373335820106"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "instance"
		
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for memory metrics graph data
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare graphite_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for unknown metrics
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for GraphiteRestPlugin|||unknown found"
		
	Scenario: Compare graphite_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for unknown metrics graph data
		When I post to "/graphite_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for GraphiteRestPlugin|||unknown found" 

	Scenario: Compare graphite_comparison_app (overhead) main invalid test key-one+key-two for memory metrics
		When I post to "/graphite_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of graphite_comparison_app/invalid found"
		
	Scenario: Compare graphite_comparison_app (overhead) main invalid test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/graphite_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of graphite_comparison_app/invalid found" 
		
	Scenario: Compare graphite_comparison_app (overhead) invalid load test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/graphite_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 

	Scenario: Compare invalid main load test key-one and key-two for memory metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare invalid (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two for memory metrics
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "carbon.agents.graphite-a.memUsage"
		And the message should contain "key-four"
		And the message should contain "key-three"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "11.075134201771649"
		And the message should contain "10.827373335820106"
		And the message should contain "38080716.8"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two for memory metrics for graph data
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two and key-three for memory metrics
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four+key-five", 
			"plugin_id": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And the message should contain "carbon.agents.graphite-a.cpuUsage"
		And the message should contain "carbon.agents.graphite-a.memUsage"
		And the message should contain "key-five"
		And the message should contain "key-four"
		And the message should contain "key-three"
		And the message should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the message should contain "11.075134201771649"
		And the message should contain "10.827373335820106"
		And the message should contain "38080716.8"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two and key-three for memory metrics for graph data
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four,key-five", 
			"plugin": "GraphiteRestPlugin|||graphite_time_series"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two for unknown metrics
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four+key-five", 
			"plugin_id": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for GraphiteRestPlugin|||unknown found"
		
	Scenario: Compare graphite_singular_app (singular) main load test key-one and key-two for unknown metrics for graph data
		When I post to "/graphite_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four,key-five", 
			"plugin": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for GraphiteRestPlugin|||unknown found" 

	Scenario: Compare graphite_singular_app (singular) main invalid test key-one and key-two for memory metrics
		When I post to "/graphite_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four+key-five", 
			"plugin_id": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of graphite_singular_app/invalid found"
		
	Scenario: Compare graphite_singular_app (singular) main invalid test key-one and key-two for memory metrics for graph data
		When I post to "/graphite_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four,key-five", 
			"plugin": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of graphite_singular_app/invalid found" 
		
	Scenario: Compare graphite_singular_app (singular) invalid load test key-one and key-two for memory metrics
		When I post to "/graphite_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four+key-five", 
			"plugin_id": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"
		
	Scenario: Compare graphite_singular_app (singular) invalid load test key-one and key-two for memory metrics for graph data
		When I post to "/graphite_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four,key-five", 
			"plugin": "GraphiteRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 		