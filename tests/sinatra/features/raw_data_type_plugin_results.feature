Feature: Repose Plugin Page
	In order to view repose plugin data
	As a performance test user
	I want to view the jmx results

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with filters jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with gc jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/gc'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_gc_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_memory jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/jvm_memory'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_memory_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with logs jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/logs'
		Then the response should be "404"
		And the error page should match the "no metric data found for atom_hopper/main/load_test/e464b1b6-10ab-4332-8b30-8439496c2d19/ReposeJmxPlugin/logs"

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/jvm_threads'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_threads_results" version

	Scenario: Load atom_hopper main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with unknown jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/unknown'
		Then the response should be "404"
		And the error page should match the "no metric data found for atom_hopper/main/load_test/e464b1b6-10ab-4332-8b30-8439496c2d19/ReposeJmxPlugin/unknown"

	Scenario: Load atom_hopper main load test for none with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/main/load_test/id/none/plugin/ReposeJmxPlugin/jvm_threads'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_threads_results_unknown" version

	Scenario: Load atom_hopper main none test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/main/none/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/jvm_threads'
		Then the response should be "404"
		And the error page should match the "No application by name of atom_hopper/none found"

	Scenario: Load atom_hopper none load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/atom_hopper/results/none/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/jvm_threads'
		Then the response should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for e464b1b6-10ab-4332-8b30-8439496c2d19 with jvm_threads jmx metrics
		When I navigate to '/none/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/jvm_threads'
		Then the response should be "404"
		And the error page should match the "No application by name of none/load_test found"