Feature: Jenkins Plugin Page
	In order to view jenkins_singular_app plugin data
	As a performance test user
	I want to view the rest jmx results

	Scenario: Load jenkins_singular_app main load test for key-one with rest metrics
		When I navigate to '/jenkins_singular_app/results/main/load_test/id/key-one/plugin/JenkinsRestPlugin/status'
		Then the page response status code should be "200"
		And the page should contain "status"
		And the page should contain "gabe.westmaas"
		And the page should contain "userId"
		And the page should contain "userName"
		And the page should contain "estimatedDuration"
		And the page should contain "executor"
		And the page should contain "changeSet"
		And the page should contain "2034-03-07_36-23-27"

	Scenario: Load jenkins_singular_app main load test for key-two with rest metrics
		When I navigate to '/jenkins_singular_app/results/main/load_test/id/key-two/plugin/JenkinsRestPlugin/status'
		Then the page response status code should be "200"
		And the page should contain "status"
		And the page should contain "gabe.westmaas"
		And the page should contain "userId"
		And the page should contain "userName"
		And the page should contain "estimatedDuration"
		And the page should contain "executor"
		And the page should contain "changeSet"
		And the page should contain "2014-03-07_16-23-27"

	Scenario: Load jenkins_singular_app main load test for key-three with unknown jmx metrics
		When I navigate to '/jenkins_singular_app/results/main/load_test/id/key-three/plugin/JenkinsRestPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for jenkins_singular_app/main/load_test/key-three/JenkinsRestPlugin/unknown"

	Scenario: Load jenkins_singular_app main load test for none with rest jmx metrics
		When I navigate to '/jenkins_singular_app/results/main/load_test/id/none/plugin/JenkinsRestPlugin/rest_time_series'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for jenkins_singular_app/main/load_test/none/JenkinsRestPlugin/rest_time_series"

	Scenario: Load jenkins_singular_app main none test for key-three with rest jmx metrics
		When I navigate to '/jenkins_singular_app/results/main/none/id/key-three/plugin/JenkinsRestPlugin/rest_time_series'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of jenkins_singular_app/none found"

	Scenario: Load jenkins_singular_app none load test for key-three with rest jmx metrics
		When I navigate to '/jenkins_singular_app/results/none/load_test/id/key-three/plugin/JenkinsRestPlugin/rest_time_series'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-three with rest jmx metrics
		When I navigate to '/none/results/main/load_test/id/key-three/plugin/JenkinsRestPlugin/rest_time_series'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"