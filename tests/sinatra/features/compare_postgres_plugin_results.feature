Feature: Compare Postgres Plugin Page
	In order to compare tests with postgres plugin data
	As a performance test user
	I want to compare the postgres tests

	Scenario: Compare postgres_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for rows metrics
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_comparison_app_compare_plugin_results_postgres_plugin_rows" version
		
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one,key-four,key-two,key-five for rows metrics graph data
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response
	
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+key-three for rows metrics
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_comparison_app_compare_plugin_results_postgres_plugin_rows_w_key_three_filters" version
		
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for rows metrics graph data
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare postgres_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+invalid-key-three for rows metrics
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_comparison_app_compare_plugin_results_postgres_plugin_rows" version
		
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one,key-four,invalid-key-three,key-two,key-five for rows metrics graph data
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare postgres_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for rows metrics
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_comparison_app_compare_plugin_results_postgres_plugin_rows_only_key_one" version
		
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for rows metrics graph data
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare postgres_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for unknown metrics
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for PostgresPlugin|||rows found"
		
	Scenario: Compare postgres_comparison_app (overhead) main load test key-one,key-four,key-three,key-two,key-five for unknown metrics graph data
		When I post to "/postgres_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for PostgresPlugin|||rows found" 

	Scenario: Compare postgres_comparison_app (overhead) main invalid test key-one+key-two for rows metrics
		When I post to "/postgres_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of postgres_comparison_app/invalid found"
		
	Scenario: Compare postgres_comparison_app (overhead) main invalid test key-one,key-four,key-three,key-two,key-five for rows metrics graph data
		When I post to "/postgres_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of postgres_comparison_app/invalid found" 
		
	Scenario: Compare postgres_comparison_app (overhead) invalid load test key-one,key-four,key-three,key-two,key-five for rows metrics graph data
		When I post to "/postgres_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 

	Scenario: Compare invalid main load test key-one and key-two for rows metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare invalid (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two for rows metrics
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_singular_app_compare_plugin_results_postgres_plugin_rows" version
		
	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two for rows metrics for graph data
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two and key-three for rows metrics
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And the page should match the "postgres_singular_app_compare_plugin_results_postgres_plugin_w_key_three_filters" version
		
	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two and key-three for rows metrics for graph data
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two for unknown metrics
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for PostgresPlugin|||unknown found"
		
	Scenario: Compare postgres_singular_app (singular) main load test key-one and key-two for unknown metrics for graph data
		When I post to "/postgres_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "PostgresPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for PostgresPlugin|||unknown found" 

	Scenario: Compare postgres_singular_app (singular) main invalid test key-one and key-two for rows metrics
		When I post to "/postgres_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of postgres_singular_app/invalid found"
		
	Scenario: Compare postgres_singular_app (singular) main invalid test key-one and key-two for rows metrics for graph data
		When I post to "/postgres_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of postgres_singular_app/invalid found" 
		
	Scenario: Compare postgres_singular_app (singular) invalid load test key-one and key-two for rows metrics
		When I post to "/postgres_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No sub application for invalid found"
		
	Scenario: Compare postgres_singular_app (singular) invalid load test key-one and key-two for rows metrics for graph data
		When I post to "/postgres_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "PostgresPlugin|||rows"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 		