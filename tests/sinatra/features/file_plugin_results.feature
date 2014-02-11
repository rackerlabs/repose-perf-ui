Feature: File Plugin Page
	In order to view file_singular_app plugin data
	As a performance test user
	I want to view the large files

	Scenario: Load file_singular_app main load test for key-three with file metrics
		When I navigate to '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "carbon.agents.graphite-a.cpuUsage"
		And the page should contain "carbon.agents.graphite-a.memUsage"
		And the page should contain "graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "file - graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "11.075134201771649"
		And the page should contain "Detailed Test Results for graphitedata.out_graphite.drivesrvr-dev.com"
		And the page should contain "2013-12-25T20:34:00+00:00"
		
	Scenario: Search file_singular_app for all occurrences of string
		Given I navigate to '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file'
		When I click on 'search'
		And I enter "Using regex capture groups is recommended to help Repose build replicable, meaningful cache IDs for rate limits. Please update your config."
		And I click on 'submit search'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "15" occurrences of "Using regex capture groups is recommended to help Repose build replicable, meaningful cache IDs for rate limits. Please update your config."

	Scenario: Load file_singular_app main load test for key-three with unknown metric
		When I navigate to '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for file_singular_app/main/load_test/key-three/FilePlugin/unknown"

	Scenario: Load file_singular_app main load test for none with file metrics
		When I navigate to '/file_singular_app/results/main/load_test/id/none/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for file_singular_app/main/load_test/none/FilePlugin/file"

	Scenario: Load file_singular_app main none test for key-three with file metrics
		When I navigate to '/file_singular_app/results/main/none/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of file_singular_app/none found"

	Scenario: Load file_singular_app none load test for key-three with file metrics
		When I navigate to '/file_singular_app/results/none/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-three with file metrics
		When I navigate to '/none/results/main/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"