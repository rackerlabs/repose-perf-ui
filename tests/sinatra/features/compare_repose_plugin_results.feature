Feature: Repose Plugin Page
	In order to compare tests with repose plugin data
	As a performance test user
	I want to compare the jmx results across 2+ tests

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the message should contain "http-logging:75thPercentile"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "2.142857142857143"
		And the message should contain "2.0"
		And the message should contain "2.142857142857143"
		And the message should contain "2.2857142857142856"
		And the message should contain "translation:75thPercentile"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-four for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response
	
	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two and key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the message should contain "http-logging:75thPercentile"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "2.142857142857143"
		And the message should contain "2.0"
		And the message should contain "2.142857142857143"
		And the message should contain "2.2857142857142856"
		And the message should contain "translation:75thPercentile"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two and invalid-key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the message should contain "http-logging:75thPercentile"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "2.142857142857143"
		And the message should contain "2.0"
		And the message should contain "2.142857142857143"
		And the message should contain "2.2857142857142856"
		And the message should contain "translation:75thPercentile"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, invalid-key-three, key-four for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,invalid-key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for ReposeJmxPlugin|||filters found"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, invalid-key-two, invalid-key-three for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"invalid-key-one,key-four,invalid-key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "1" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for gc jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And the message should contain "PSMarkSweep.CollectionTime"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "jmxdata.out_162.209.124.167"
		And the message should contain "0.0"
		And the message should contain "0.25"
		And the message should contain "79.25"
		And the message should contain "1157.25"
		And the message should contain "421.75"
		And the message should contain "1134.0"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-four for gc jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "4" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And the message should contain "HeapMemoryUsage.committed"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "jmxdata.out_162.209.124.167"
		And the message should contain "386301952.0"
		And the message should contain "231901507.0"
		And the message should contain "388587520.0"
		And the message should contain "192118440.0"
		And the message should contain "3491561472.0"
		And the message should contain "245467264.0"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for jvm_memory jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And the message should contain "PeakThreadCount"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "jmxdata.out_162.209.124.158"
		And the message should contain "jmxdata.out_162.209.124.167"
		And the message should contain "41.875"
		And the message should contain "17.5"
		And the message should contain "41.125"
		And the message should contain "44.875"
		And the message should contain "44.25"
		And the message should contain "41.0"
		And the message should contain "instance"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for jvm_threads jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "5" records in response

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for logs jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for ReposeJmxPlugin|||logs found"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for logs jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for ReposeJmxPlugin|||logs found" 

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for unknown jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for ReposeJmxPlugin|||unknown found"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for unknown jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "no data for ReposeJmxPlugin|||unknown found" 

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jmx threads none metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No plugin by name of unknown found"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter unknown graph data
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No plugin by name of unknown found" 

	Scenario: Compare repose_comparison_app (overhead) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of repose_comparison_app/invalid found"
		
	Scenario: Compare repose_comparison_app (overhead) main invalid test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of repose_comparison_app/invalid found" 

	Scenario: Compare repose_comparison_app (overhead) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"
		
	Scenario: Compare repose_comparison_app (overhead) invalid load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/repose_comparison_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
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
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare repose_comparison_app (overhead) main load test key-one, key-two, key-five, key-three, key-four for filter jmx metrics graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for filters jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the message should contain "http-logging:75thPercentile"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "2.142857142857143"
		And the message should contain "2.2857142857142856"
		And the message should contain "translation:75thPercentile"
		And the message should contain "instance"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for filters jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-two", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two and key-three for filters jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the message should contain "http-logging:75thPercentile"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-three"
		And the message should contain "2.142857142857143"
		And the message should contain "2.2857142857142856"
		And the message should contain "translation:75thPercentile"
		And the message should contain "instance"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two and key-three for filters jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for gc jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "79.25"
		And the message should contain "0.25"
		And the message should contain "1134.0"
		And the message should contain "PSMarkSweep.CollectionTime"
		And the message should contain "instance"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for gc jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "386301952.0"
		And the message should contain "231901507.0"
		And the message should contain "3491561472.0"
		And the message should contain "HeapMemoryUsage.committed"
		And the message should contain "instance"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_memory jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "41.75"
		And the message should contain "17.5"
		And the message should contain "41.0"
		And the message should contain "PeakThreadCount"
		And the message should contain "instance"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_threads jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-three,key-two", 
			"plugin": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "3" records in response

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for logs jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for ReposeJmxPlugin|||logs found"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for logs jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for ReposeJmxPlugin|||logs found" 

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for unknown jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for ReposeJmxPlugin|||unknown found"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for unknown jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for ReposeJmxPlugin|||unknown found" 

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jmx threads none metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No plugin by name of unknown found"
		
	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for filters none metrics for graph data
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No plugin by name of unknown found" 

	Scenario: Compare repose_singular_app (singular) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of repose_singular_app/invalid found"
		
	Scenario: Compare repose_singular_app (singular) main invalid test key-one and key-two for filters jmx metrics for graph data
		When I post to "/repose_singular_app/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of repose_singular_app/invalid found" 
		
	Scenario: Compare repose_singular_app (singular) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"
		
	Scenario: Compare repose_singular_app (singular) invalid load test key-one and key-two for filters jmx metrics for graph data
		When I post to "/repose_singular_app/results/invalid/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"key-one,key-four,key-three,key-two,key-five", 
			"plugin": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No sub application for invalid found" 		
