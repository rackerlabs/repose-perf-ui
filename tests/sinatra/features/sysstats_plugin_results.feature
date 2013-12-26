Feature: Sysstats Plugin Page
	In order to view repose plugin data
	As a performance test user
	I want to view the sysstats results

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with cpu metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/cpu'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_cpu.out_10.23.246.101-all"
		And the page should contain "%user"
		And the page should contain "cpu - sysstats_cpu.out_10.23.246.101-all"
		And the page should contain "3.96"
		And the page should contain "Detailed Test Results for sysstats_cpu.out_10.23.246.101-all"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with kernel metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/kernel'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_kernel.out_10.23.246.101"
		And the page should contain "dentunusd"
		And the page should contain "kernel - sysstats_kernel.out_10.23.246.101"
		And the page should contain "44439"
		And the page should contain "Detailed Test Results for sysstats_kernel.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with memory swap metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/memory_swap'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_memory_swap.out_10.23.246.101"
		And the page should contain "kbswpfree"
		And the page should contain "memory_swap - sysstats_memory_swap.out_10.23.246.101"
		And the page should contain "0"
		And the page should contain "Detailed Test Results for sysstats_memory_swap.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with memory page metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/memory_page'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_memory_page.out_10.23.246.101"
		And the page should contain "frmpg/s"
		And the page should contain "memory_page - sysstats_memory_page.out_10.23.246.101"
		And the page should contain "-20.98"
		And the page should contain "Detailed Test Results for sysstats_memory_page.out_10.23.246.101"
		And the page should contain "06:35:06 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with memory utilization metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/memory_utilization'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_memory_utilization.out_10.23.246.101"
		And the page should contain "kbmemfree"
		And the page should contain "memory_utilization - sysstats_memory_utilization.out_10.23.246.101"
		And the page should contain "14149690"
		And the page should contain "Detailed Test Results for sysstats_memory_utilization.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with tcp network failure metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/tcp_failure_network'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_tcp_failure_network.out_10.23.246.101"
		And the page should contain "atmptf/s"
		And the page should contain "tcp_failure_network - sysstats_tcp_failure_network.out_10.23.246.101"
		And the page should contain "0.00"
		And the page should contain "Detailed Test Results for sysstats_tcp_failure_network.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with tcp network metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/tcp_network'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_tcp_network.out_10.23.246.101"
		And the page should contain "active/s"
		And the page should contain "tcp_network - sysstats_tcp_network.out_10.23.246.101"
		And the page should contain "305.28"
		And the page should contain "Detailed Test Results for sysstats_tcp_network.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with ip failure network metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/ip_failure_network'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_ip_failure_network.out_10.23.246.101"
		And the page should contain "ihdrerr/s"
		And the page should contain "ip_failure_network - sysstats_ip_failure_network.out_10.23.246.101"
		And the page should contain "0.00"
		And the page should contain "Detailed Test Results for sysstats_ip_failure_network.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with ip network metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/ip_network'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_ip_network.out_10.23.246.101"
		And the page should contain "irec/s"
		And the page should contain "ip_network - sysstats_ip_network.out_10.23.246.101"
		And the page should contain "2521.26"
		And the page should contain "Detailed Test Results for sysstats_ip_network.out_10.23.246.101"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with device network metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_network'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_device_network.out_10.23.246.101-lo"
		And the page should contain "sysstats_device_network.out_10.23.246.101-eth1"
		And the page should contain "sysstats_device_network.out_10.23.246.101-eth0"
		And the page should contain "rxpck/s"
		And the page should contain "device_network - sysstats_device_network.out_10.23.246.101-lo"
		And the page should contain "device_network - sysstats_device_network.out_10.23.246.101-eth1"
		And the page should contain "device_network - sysstats_device_network.out_10.23.246.101-eth0"
		And the page should contain "736.57"
		And the page should contain "Detailed Test Results for sysstats_device_network.out_10.23.246.101-lo"
		And the page should contain "Detailed Test Results for sysstats_device_network.out_10.23.246.101-eth1"
		And the page should contain "Detailed Test Results for sysstats_device_network.out_10.23.246.101-eth0"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with device disk metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_disk'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_device_disk.out_10.23.246.101-dev202-64"
		And the page should contain "sysstats_device_disk.out_10.23.246.101-dev202-0"
		And the page should contain "tps"
		And the page should contain "device_disk - sysstats_device_disk.out_10.23.246.101"
		And the page should contain "0.49"
		And the page should contain "Detailed Test Results for sysstats_device_disk.out_10.23.246.101"
		And the page should contain "06:35:06 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with device failure metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_failure'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "sysstats_device_failure.out_10.23.246.101-lo"
		And the page should contain "sysstats_device_failure.out_10.23.246.101-eth1"
		And the page should contain "sysstats_device_failure.out_10.23.246.101-eth0"
		And the page should contain "rxerr/s"
		And the page should contain "device_failure - sysstats_device_failure.out_10.23.246.101-lo"
		And the page should contain "device_failure - sysstats_device_failure.out_10.23.246.101-eth1"
		And the page should contain "device_failure - sysstats_device_failure.out_10.23.246.101-eth0"
		And the page should contain "0.00"
		And the page should contain "Detailed Test Results for sysstats_device_failure.out_10.23.246.101-lo"
		And the page should contain "Detailed Test Results for sysstats_device_failure.out_10.23.246.101-eth1"
		And the page should contain "Detailed Test Results for sysstats_device_failure.out_10.23.246.101-eth0"
		And the page should contain "06:34:36 PM"

	Scenario: Load sysstats main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with unknown metrics
		When I navigate to '/sysstats/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for sysstats/main/load_test/a4f791ae-1a10-446b-9055-e1130cc53bec/SysstatsPlugin/unknown"

	Scenario: Load sysstats main load test for invalid with device failure metrics
		When I navigate to '/sysstats/results/main/load_test/id/none/plugin/SysstatsPlugin/device_failure'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "rxerr/s"
		And the page should not contain "sysstats_device_failure.out_10.23.246.101-lo"
		And the page should not contain "device_failure - sysstats_device_failure.out_10.23.246.101-eth0"
		And the page should not contain "0.00"
		And the page should not contain "Detailed Test Results for sysstats_device_failure.out_10.23.246.101-lo"

	Scenario: Load sysstats main none test for a4f791ae-1a10-446b-9055-e1130cc53bec with device_failure metrics
		When I navigate to '/sysstats/results/main/none/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_failure'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of sysstats/none found"

	Scenario: Load sysstats none load test for a4f791ae-1a10-446b-9055-e1130cc53bec with device_failure metrics
		When I navigate to '/sysstats/results/none/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_failure'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for a4f791ae-1a10-446b-9055-e1130cc53bec with device_failure metrics
		When I navigate to '/none/results/main/load_test/id/a4f791ae-1a10-446b-9055-e1130cc53bec/plugin/SysstatsPlugin/device_failure'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"