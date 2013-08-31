Feature: Test Page
	In order to view current tests
	As a performance test user
	I want to view the current tests page

	Scenario: Navigate to current tests page
		When I navigate to '/tests'
		Then the response should be "200"
		And the page should contain "dbaas,ah,csl,passthrough,ddrl,metrics_on_off" applications

	Scenario: Navigate to dbaas application test page
		When I navigate to '/tests/dbaas'
		Then the response should be "200"
		And the page should contain "load_test,duration_test,benchmark_test,adhoc_test" test types

	Scenario: Navigate to invalid application test page
		When I navigate to '/tests/invalid'
		Then the response should be "404"

	Scenario: Navigate to dbaas load test application test page
		When I navigate to '/tests/dbaas/load_test'
		Then the response should be "200"
		And the page should match the "dbaas_load_test" version

	Scenario: Navigate to dbaas duration test application test page
		When I navigate to '/tests/dbaas/duration_test'
		Then the response should be "200"
		And the page should match the "dbaas_duration_test" version

	Scenario: Navigate to invalid app load test application test page
		When I navigate to '/tests/invalid/load_test'
		Then the response should be "404"

	Scenario: Navigate to dbaas invalid test application test page
		When I navigate to '/tests/dbaas/invalid_test'
		Then the response should be "404"

	Scenario: Load dbaas load test average response time metric with test ended
		When I navigate to '/tests/dbaas/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load dbaas adhoc test average response time metric
		When I navigate to '/tests/dbaas/adhoc_test'
		And I navigate to '/tests/dbaas/adhoc_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "506" records in response

	Scenario: Load dbaas load test throughput metric
		When I navigate to '/tests/dbaas/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "0" records in response

	Scenario: Load dbaas adhoc test errors metric
		When I navigate to '/tests/dbaas/adhoc_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "506" records in response

	Scenario: Load dbaas load test invalid metric
		When I navigate to '/tests/dbaas/load_test/metric/invalid'
		Then the response should be "200"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load dbaas invalid test errors metric
		When I navigate to '/tests/dbaas/invalid_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load invalid app load test errors metric
		When I navigate to '/tests/invalid/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live dbaas load test average response time metric with test ended
		When I navigate to '/tests/dbaas/load_test'
		And I navigate to '/tests/dbaas/load_test/metric/avg/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live dbaas adhoc test average response time metric
		When I navigate to '/tests/dbaas/adhoc_test'
		And I navigate to '/tests/dbaas/adhoc_test/metric/avg/live'
		Then the response should be "200"
		And response should be a json
		And there should be "0" records in response
		And the test should not have ended

	Scenario: Load live dbaas load test throughput metric
		When I navigate to '/tests/dbaas/load_test'
		And I navigate to '/tests/dbaas/load_test/metric/throughput/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live dbaas load test errors metric
		When I navigate to '/tests/dbaas/load_test'
		And I navigate to '/tests/dbaas/load_test/metric/errors/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live dbaas load test invalid metric
		When I navigate to '/tests/dbaas/load_test'
		And I navigate to '/tests/dbaas/load_test/metric/invalid/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live dbaas invalid test errors metric
		When I navigate to '/tests/dbaas/invalid_test/metric/errors/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended

	Scenario: Load live invalid app load test errors metric
		When I navigate to '/tests/invalid/load_test/metric/errors/live'
		Then the response should be "404"
		And response should be a json
		And there should be "0" records in response
		And the test should have ended
