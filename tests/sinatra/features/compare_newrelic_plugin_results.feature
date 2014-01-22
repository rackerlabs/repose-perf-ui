Feature: Compare NewRelic Plugin Page
	In order to compare tests with newrelic plugin data
	As a performance test user
	I want to compare the newrelic tests

	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for memory metrics
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-four"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-five"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one,key-four,key-two,key-five for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response
	
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+key-three for memory metrics
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-four"
		And the message should contain "key-one"
		And the message should contain "key-three"
		And the message should contain "key-two"
		And the message should contain "key-five"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+invalid-key-three for memory metrics
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-four"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-five"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one,key-four,invalid-key-three,key-two,key-five for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare newrelic_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for memory metrics
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-one"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for unknown metrics
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "NewrelicRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for NewrelicRestPlugin|||unknown found"
		
	Scenario: Compare newrelic_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for unknown metrics graph data
		When I post to "/newrelic_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for NewrelicRestPlugin|||unknown found" 

	Scenario: Compare newrelic_comparison_app (overhead) main invalid test key-one+key-two for memory metrics
		When I post to "/newrelic_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of newrelic_comparison_app/invalid found"
		
	Scenario: Compare newrelic_comparison_app (overhead) main invalid test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of newrelic_comparison_app/invalid found" 
		
	Scenario: Compare newrelic_comparison_app (overhead) invalid load test key-one,key-four,key-three,key-two,key-five for memory metrics graph data
		When I post to "/newrelic_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
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
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare invalid (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two for memory metrics
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-four"
		And the message should contain "key-three"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two for memory metrics for graph data
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two and key-three for memory metrics
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four+key-five", 
			"plugin_id": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the message should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the message should contain "key-four"
		And the message should contain "key-three"
		And the message should contain "key-five"
		And the message should contain "average_response_time"
		And the message should contain "0.0"
		And the message should contain "instance"
		And the message should contain "key"
		
	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two and key-three for memory metrics for graph data
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-four,key-three,key-five", 
			"plugin": "NewrelicRestPlugin|||newrelic"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two for unknown metrics
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four", 
			"plugin_id": "NewrelicRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for NewrelicRestPlugin|||unknown found"
		
	Scenario: Compare newrelic_singular_app (singular) main load test key-one and key-two for unknown metrics for graph data
		When I post to "/newrelic_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four", 
			"plugin": "NewrelicRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for NewrelicRestPlugin|||unknown found" 

	Scenario: Compare newrelic_singular_app (singular) main invalid test key-one and key-two for memory metrics
		When I post to "/newrelic_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four", 
			"plugin_id": "NewrelicRestPlugin|||memory"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of newrelic_singular_app/invalid found"
		
	Scenario: Compare newrelic_singular_app (singular) main invalid test key-one and key-two for memory metrics for graph data
		When I post to "/newrelic_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four", 
			"plugin": "NewrelicRestPlugin|||memory"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of newrelic_singular_app/invalid found" 
		
	Scenario: Compare newrelic_singular_app (singular) invalid load test key-one and key-two for memory metrics
		When I post to "/newrelic_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-three+key-four", 
			"plugin_id": "NewrelicRestPlugin|||memory"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"
		
	Scenario: Compare newrelic_singular_app (singular) invalid load test key-one and key-two for memory metrics for graph data
		When I post to "/newrelic_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-three,key-four", 
			"plugin": "NewrelicRestPlugin|||memory"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 		