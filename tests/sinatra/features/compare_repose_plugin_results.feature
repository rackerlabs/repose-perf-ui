Feature: Repose Plugin Page
	In order to compare tests with repose plugin data
	As a performance test user
	I want to compare the jmx results across 2+ tests

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two and key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two and invalid-key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+invalid-key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test invalid-key-one and key-two and invalid-key-three for filters jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-two+invalid-key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for gc jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for logs jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for unknown jmx metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_comparison_app (overhead) main load test key-one and key-two for jmx threads none metrics
		When I post to "/repose_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No plugin by name of unknown found"

	Scenario: Compare repose_comparison_app (overhead) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of repose_comparison_app/invalid found"

	Scenario: Compare repose_comparison_app (overhead) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_comparison_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No sub application for invalid found"

	Scenario: Compare invalid main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of invalid/load_test found"

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for filters jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two and key-three for filters jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for gc jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||gc"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_memory jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_memory"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||jvm_threads"
		  }
		"""
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for logs jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of repose_comparison_app/load_test found"

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for unknown jmx metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of repose_comparison_app/load_test found"

	Scenario: Compare repose_singular_app (singular) main load test key-one and key-two for jmx threads none metrics
		When I post to "/repose_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "unknown|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No plugin by name of unknown found"

	Scenario: Compare repose_singular_app (singular) main invalid test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of repose_singular_app/invalid found"
		
	Scenario: Compare repose_singular_app (singular) invalid load test key-one and key-two for jvm_threads jmx metrics
		When I post to "/repose_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "ReposeJmxPlugin|||filters"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No sub application for invalid found"