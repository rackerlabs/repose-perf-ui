Feature: Start and Stop Page
	In order to start and stop tests
	As a performance test user
	I want to be able to start and stop tests

	Scenario: Start atom_hopper main load test with jmeter for 60 minutes
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start atom_hopper main load test with jmeter for 60 minutes while another test is running
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start atom_hopper main load test with jmeter for 60 minutes with invalid data
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started atom_hopper main load test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop atom_hopper main load test with invalid guid
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start atom_hopper main duration test with jmeter for 60 minutes
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started atom_hopper main duration test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start atom_hopper main adhoc test with jmeter for 60 minutes
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started atom_hopper main adhoc test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start atom_hopper main benchmark test with jmeter for 60 minutes
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started atom_hopper main benchmark test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start overhead main load test with jmeter for 60 minutes - initial test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started overhead main load test - initial test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start overhead main load test with jmeter for 60 minutes - secondary test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop already-started overhead main load test - secondary test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Start overhead main load test with jmeter for 60 minutes with invalid comparison_guid - secondary test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop overhead main load test with invalid guid - primary test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

	Scenario: Stop overhead main load test with invalid guid - secondary test
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19/plugin/ReposeJmxPlugin/filters'
		Then the response should be "200"
		And the page should match the "singular_repose_plugin_filters_results" version

		
		