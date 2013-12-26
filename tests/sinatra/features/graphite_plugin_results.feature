Feature: Graphite Plugin Page
	In order to view graphite_singular_app plugin data
	As a performance test user
	I want to view the graphite jmx results

	Scenario: Load graphite_singular_app main load test for key-three with graphite metrics
		When I navigate to '/graphite_singular_app/results/main/load_test/id/key-three/plugin/GraphiteRestPlugin/graphite'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "carbon.agents.graphite-a.cpuUsage"
		And the page should contain "carbon.agents.graphite-a.memUsage"
		And the page should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "graphite - graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "11.075134201771649"
		And the page should contain "Detailed Test Results for graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "2013-12-25T20:34:00+00:00"

	Scenario: Load graphite_singular_app main load test for key-three with unknown jmx metrics
		When I navigate to '/graphite_singular_app/results/main/load_test/id/key-three/plugin/GraphiteRestPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for graphite_singular_app/main/load_test/key-three/GraphiteRestPlugin/unknown"

	Scenario: Load graphite_singular_app main load test for none with graphite jmx metrics
		When I navigate to '/graphite_singular_app/results/main/load_test/id/none/plugin/GraphiteRestPlugin/graphite'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for graphite_singular_app/main/load_test/none/GraphiteRestPlugin/graphite"

	Scenario: Load graphite_singular_app main none test for key-three with graphite jmx metrics
		When I navigate to '/graphite_singular_app/results/main/none/id/key-three/plugin/GraphiteRestPlugin/graphite'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of graphite_singular_app/none found"

	Scenario: Load graphite_singular_app none load test for key-three with graphite jmx metrics
		When I navigate to '/graphite_singular_app/results/none/load_test/id/key-three/plugin/GraphiteRestPlugin/graphite'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-three with graphite jmx metrics
		When I navigate to '/none/results/main/load_test/id/key-three/plugin/GraphiteRestPlugin/graphite'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"