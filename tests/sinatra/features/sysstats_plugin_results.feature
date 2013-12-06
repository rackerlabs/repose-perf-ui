Feature: Sysstats Plugin Page
	In order to view repose plugin data
	As a performance test user
	I want to view the sysstats results

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with cpu metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/cpu'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with kernel metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/kernel'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with memory swap metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/memory_swap'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with memory page metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/memory_page'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with memory utilization metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/memory_utilization'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with tcp network failure metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/tcp_failure_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with tcp network metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/tcp_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with ip failure network metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/ip_failure_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with ip network metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/ip_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with device network metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with device disk metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_disk'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with device failure metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_failure'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with unknown metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/unknown'
		Then the response should be "404"
		And the error page should match the "no metric data found for atom_hopper/main/load_test/e464b1b6-10ab-4332-8b30-8439496c2d19/ReposeJmxPlugin/unknown"

	Scenario: Load atom_hopper main load test for invalid with device failure metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/none/plugin/SysstatsPlugin/device_failure'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_threads_results_unknown" version

	Scenario: Load atom_hopper main none test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/main/none/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No application by name of atom_hopper/none found"

	Scenario: Load atom_hopper none load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/none/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/none/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No application by name of none/load_test found"

	Scenario: Load overhead main load test for some-random-string+some-random2-string with cpu metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/cpu'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with kernel metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/kernel'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with memory swap metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/memory_swap'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with memory page metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/memory_page'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with memory utilization metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/memory_utilization'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with tcp network failure metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/tcp_failure_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with tcp network metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/tcp_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with ip failure network metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/ip_failure_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with ip network metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/ip_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with device network metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_network'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with device disk metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_disk'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with device failure metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_failure'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load overhead main load test for some-random-string+some-random2-string with unknown metrics
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/unknown'
		Then the response should be "404"
		And the error page should match the "no metric data found for overhead/main/load_test/some-random-string+some-random2-string/ReposeJmxPlugin/unknown"

	Scenario: Load overhead main load test for invalid with device failure metrics
		When I navigate to '/overhead/results/main/load_test/id/none/plugin/SysstatsPlugin/device_failure'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_threads_results_unknown" version

	Scenario: Load overhead main none test for some-random-string+some-random2-string with jvm_threads jmx metrics
		When I navigate to '/overhead/results/main/none/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No application by name of overhead/none found"

	Scenario: Load overhead none load test for some-random-string+some-random2-string with jvm_threads jmx metrics
		When I navigate to '/overhead/results/none/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for some-random-string+some-random2-string with jvm_threads jmx metrics
		When I navigate to '/none/results/main/load_test/id/some-random-string+some-random2-string/plugin/SysstatsPlugin/device_failure'
		Then the response should be "404"
		And the error page should match the "No application by name of none/load_test found"		