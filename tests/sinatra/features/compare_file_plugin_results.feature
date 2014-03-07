Feature: File Plugin Page
	In order to compare tests with repose plugin data
	As a performance test user
	I want to compare the jmx results across 2+ tests

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for file metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-four for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two and key-three for file metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two and invalid-key-three for file metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, invalid-key-three, key-four for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for file metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for gc jmx metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five",
			"plugin_id": "FilePlugin|||gc"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||gc found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-four for gc jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five",
			"plugin": "FilePlugin|||gc"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five",
			"plugin_id": "FilePlugin|||jvm_memory"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||jvm_memory found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for jvm_memory jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||jvm_memory"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five",
			"plugin_id": "FilePlugin|||jvm_threads"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||jvm_threads found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for jvm_threads jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||jvm_threads"
		  }
		"""
		Then the response should be "404"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for logs jmx metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five",
			"plugin_id": "FilePlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for FilePlugin|||logs found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for logs jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for FilePlugin|||logs found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for unknown jmx metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for FilePlugin|||unknown found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for unknown jmx metrics graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "no data for FilePlugin|||unknown found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one and key-two for jmx threads none metrics
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "unknown|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No plugin by name of unknown found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter unknown graph data
		When I post to "/file_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "unknown|||file"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No plugin by name of unknown found"

	Scenario: Compare file_comparison_app (overhead) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of file_comparison_app/invalid found"

	Scenario: Compare file_comparison_app (overhead) main invalid test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of file_comparison_app/invalid found"

	Scenario: Compare file_comparison_app (overhead) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_comparison_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"

	Scenario: Compare file_comparison_app (overhead) invalid load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/file_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found"

	Scenario: Compare invalid main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"

	Scenario: Compare file_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for file metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for file metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two and key-three for file metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "200"
		And the message should contain "No comparison available for this plugin"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two and key-three for file metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for gc jmx metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||gc"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||gc found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for gc jmx metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two",
			"plugin": "FilePlugin|||gc"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||jvm_memory"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||jvm_memory found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for jvm_memory jmx metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two",
			"plugin": "FilePlugin|||jvm_memory"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||jvm_threads"
		  }
		"""
		Then the response should be "404"
		And the message should contain "No data for FilePlugin|||jvm_threads found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for jvm_threads jmx metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two",
			"plugin": "FilePlugin|||jvm_threads"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for logs jmx metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for FilePlugin|||logs found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for logs jmx metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for FilePlugin|||logs found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for unknown jmx metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for FilePlugin|||unknown found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for unknown jmx metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for FilePlugin|||unknown found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for jmx threads none metrics
		When I post to "/file_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "unknown|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No plugin by name of unknown found"

	Scenario: Compare file_singular_app (singular) main load test key-one and key-two for file none metrics for graph data
		When I post to "/file_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "unknown|||file"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No plugin by name of unknown found"

	Scenario: Compare file_singular_app (singular) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of file_singular_app/invalid found"

	Scenario: Compare file_singular_app (singular) main invalid test key-one and key-two for file metrics for graph data
		When I post to "/file_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of file_singular_app/invalid found"

	Scenario: Compare file_singular_app (singular) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/file_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two",
			"plugin_id": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"

	Scenario: Compare file_singular_app (singular) invalid load test key-one and key-two for file metrics for graph data
		When I post to "/file_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five",
			"plugin": "FilePlugin|||file"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found"
