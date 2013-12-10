Feature: Repose Plugin Page
	In order to compare tests with repose plugin data
	As a performance test user
	I want to compare the jmx results across 2+ tests

	Scenario: Compare sysstats main load test for cpu
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_cpu" version
		
	Scenario: Compare sysstats main load test for cpu graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response
	
	Scenario: Compare sysstats main load test for ip network
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||ip_network"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_ip_network" version
		
	Scenario: Compare sysstats main load test for ip network graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||ip_network"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for ip_failure_network
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||ip_failure_network"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_ip_failure_network" version
		
	Scenario: Compare sysstats main load test for ip_failure_network graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||ip_failure_network"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for device_network
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||device_network"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_device_network" version
		
	Scenario: Compare sysstats main load test for device_network graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||device_network"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for memory_page
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||memory_page"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_memory_page" version
		
	Scenario: Compare sysstats main load test for memory_page graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||memory_page"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for device_failure
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||device_failure"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_device_failure" version
		
	Scenario: Compare sysstats main load test for device_failure graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||device_failure"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for memory_swap
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||memory_swap"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_memory_swap" version
		
	Scenario: Compare sysstats main load test for memory_swap graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||memory_swap"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for kernel
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||kernel"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_kernel" version
		
	Scenario: Compare sysstats main load test for kernel graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||kernel"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for tcp_failure_network
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||tcp_failure_network"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_tcp_failure_network" version
		
	Scenario: Compare sysstats main load test for tcp_failure_network graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||tcp_failure_network"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for memory_utilization
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||memory_utilization"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_memory_utilization" version
		
	Scenario: Compare sysstats main load test for memory_utilization graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||memory_utilization"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for device_disk
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||device_disk"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_device_disk" version
		
	Scenario: Compare sysstats main load test for device_disk graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||device_disk"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare sysstats main load test for tcp_network
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||tcp_network"
		  }
		"""
		Then the response should be "200"
		And the page should match the "sysstats_compare_plugin_results_sysstats_tcp_network" version
		
	Scenario: Compare sysstats main load test for tcp_network graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||tcp_network"
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And there should be "2" records in response

	Scenario: Compare invalid main load test for cpu
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of invalid/load_test found"
		
	Scenario: Compare invalid main load test for cpu graph data
		When I post to "/invalid/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "404"
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of invalid/load_test found" 

	Scenario: Compare sysstats main load test for logs 
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for SysstatsPlugin|||logs found"
		
	Scenario: Compare sysstats main load test for logs graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||logs"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for SysstatsPlugin|||logs found" 

	Scenario: Compare sysstats main load test for unknown metrics 
		When I post to "/sysstats/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "SysstatsPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No data for SysstatsPlugin|||unknown found"
		
	Scenario: Compare sysstats main load test for unknown jmx metrics for graph data
		When I post to "/sysstats/results/main/load_test/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "no data for SysstatsPlugin|||unknown found" 

	Scenario: Compare sysstats main invalid test for cpu
		When I post to "/sysstats/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec+compare-key", 
			"plugin_id": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "404"
		And the error page should match the "No application by name of sysstats/invalid found"
		
	Scenario: Compare singular main invalid test for cpu graph data
		When I post to "/sysstats/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of sysstats/invalid found" 
		
	Scenario: Compare sysstats invalid load test 
		When I post to "/sysstats/results/main/invalid/compare-plugin/metric" with:
		"""
		  {
			"compare":"a4f791ae-1a10-446b-9055-e1130cc53bec,compare-key", 
			"plugin": "SysstatsPlugin|||cpu"
		  }
		"""
		Then the response should be "404"
		And response should be a json
		And there should be "1" records in response
		And "fail" json record should equal to "No application by name of sysstats/invalid found" 
