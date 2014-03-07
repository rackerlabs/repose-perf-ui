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
		And the message should contain "%user"
		And the message should contain "compare-key"
		And the message should contain "sysstats_cpu.out_10.23.246.101-all"
		And the message should contain "sysstats_cpu.out_162.209.124.158-all"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "3.96"
		And the message should contain "0.09"
		And the message should contain "0.00"
		And the message should contain "1.44"
		And the message should contain "0.08"
		And the message should contain "instance"
		
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
		And the message should contain "irec/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_ip_network.out_10.23.246.101"
		And the message should contain "sysstats_ip_network.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "2521.26"
		And the message should contain "68.27"
		And the message should contain "1910.63"
		And the message should contain "56.42"
		And the message should contain "instance"
		
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
		And the message should contain "ihdrerr/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_ip_failure_network.out_10.23.246.101"
		And the message should contain "sysstats_ip_failure_network.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "0.00"
		And the message should contain "instance"
		
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
		And the message should contain "rxpck/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_device_network.out_10.23.246.101-eth0"
		And the message should contain "sysstats_device_network.out_10.23.246.101-eth1"
		And the message should contain "sysstats_device_network.out_10.23.246.101-lo"
		And the message should contain "sysstats_device_network.out_162.209.124.158-eth0"
		And the message should contain "sysstats_device_network.out_162.209.124.158-eth1"
		And the message should contain "sysstats_device_network.out_162.209.124.158-lo"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "compare-key"
		And the message should contain "2521.26"
		And the message should contain "68.28"
		And the message should contain "1910.63"
		And the message should contain "56.42"
		And the message should contain "instance"
		
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
		And the message should contain "frmpg/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_memory_page.out_10.23.246.101"
		And the message should contain "sysstats_memory_page.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "-20.98"
		And the message should contain "0.06"
		And the message should contain "1.13"
		And the message should contain "-1.59"
		And the message should contain "instance"
		
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
		And the message should contain "rxerr/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_device_failure.out_10.23.246.101-eth0"
		And the message should contain "sysstats_device_failure.out_10.23.246.101-eth1"
		And the message should contain "sysstats_device_failure.out_10.23.246.101-lo"
		And the message should contain "sysstats_device_failure.out_162.209.124.158-eth0"
		And the message should contain "sysstats_device_failure.out_162.209.124.158-eth1"
		And the message should contain "sysstats_device_failure.out_162.209.124.158-lo"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "compare-key"
		And the message should contain "0.00"
		And the message should contain "instance"
		
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
		And the message should contain "kbswpfree"
		And the message should contain "compare-key"
		And the message should contain "sysstats_memory_swap.out_10.23.246.101"
		And the message should contain "sysstats_memory_swap.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "compare-key"
		And the message should contain "0.00"
		And the message should contain "instance"
		
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
		And the message should contain "dentunusd"
		And the message should contain "compare-key"
		And the message should contain "sysstats_kernel.out_10.23.246.101"
		And the message should contain "sysstats_kernel.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "44439"
		And the message should contain "517"
		And the message should contain "29209"
		And the message should contain "0"
		And the message should contain "instance"
		
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
		And the message should contain "atmptf/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_tcp_failure_network.out_10.23.246.101"
		And the message should contain "sysstats_tcp_failure_network.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "18.89"
		And the message should contain "0.00"
		And the message should contain "instance"
		
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
		And the message should contain "kbmemfree"
		And the message should contain "compare-key"
		And the message should contain "sysstats_memory_utilization.out_10.23.246.101"
		And the message should contain "sysstats_memory_utilization.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "compare-key"
		And the message should contain "7.77"
		And the message should contain "8.16"
		And the message should contain "227340"
		And the message should contain "229703"
		And the message should contain "instance"
		
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
		And the message should contain "tps"
		And the message should contain "compare-key"
		And the message should contain "sysstats_device_disk.out_10.23.246.101-dev202-0"
		And the message should contain "sysstats_device_disk.out_10.23.246.101-dev202-64"
		And the message should contain "sysstats_device_disk.out_162.209.124.158-dev202-0"
		And the message should contain "sysstats_device_disk.out_162.209.124.158-dev202-64"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "compare-key"
		And the message should contain "0.49"
		And the message should contain "9.05"
		And the message should contain "0.00"
		And the message should contain "18.36"
		And the message should contain "instance"
		
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
		And the message should contain "active/s"
		And the message should contain "compare-key"
		And the message should contain "sysstats_tcp_network.out_10.23.246.101"
		And the message should contain "sysstats_tcp_network.out_162.209.124.158"
		And the message should contain "a4f791ae-1a10-446b-9055-e1130cc53bec"
		And the message should contain "0.00"
		And the message should contain "305.28"
		And the message should contain "5.86"
		And the message should contain "2521.26"
		And the message should contain "68.24"
		And the message should contain "instance"
		
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
		And the error should match the "No application by name of invalid/load_test found"
		
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
		And the error should match the "No data for SysstatsPlugin|||logs found"
		
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
		And the error should match the "No data for SysstatsPlugin|||unknown found"
		
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
		And the error should match the "No application by name of sysstats/invalid found"
		
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
