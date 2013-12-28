Feature: New Relic Plugin Page
	In order to view newrelic_singular_app plugin data
	As a performance test user
	I want to view the newrelic jmx results

	Scenario: Load newrelic_singular_app main load test for key-three with newrelic metrics
		When I navigate to '/newrelic_singular_app/results/main/load_test/id/key-three/plugin/NewrelicRestPlugin/newrelic'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "average_response_time"
		And the page should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the page should contain "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
		And the page should contain "newrelic - Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the page should contain "0.0"
		And the page should contain "Detailed Test Results for Controller/Sinatra/MyApp/GET api/user/([^/?#]+)"
		And the page should contain "2013-12-26T22:12:00+00:00"

	Scenario: Load newrelic_singular_app main load test for key-three with unknown  metrics
		When I navigate to '/newrelic_singular_app/results/main/load_test/id/key-three/plugin/NewrelicRestPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for newrelic_singular_app/main/load_test/key-three/NewrelicRestPlugin/unknown"

	Scenario: Load newrelic_singular_app main load test for none with newrelic jmx metrics
		When I navigate to '/newrelic_singular_app/results/main/load_test/id/none/plugin/NewrelicRestPlugin/newrelic'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for newrelic_singular_app/main/load_test/none/NewrelicRestPlugin/newrelic"

	Scenario: Load newrelic_singular_app main none test for key-three with newrelic jmx metrics
		When I navigate to '/newrelic_singular_app/results/main/none/id/key-three/plugin/NewrelicRestPlugin/newrelic'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of newrelic_singular_app/none found"

	Scenario: Load newrelic_singular_app none load test for key-three with newrelic jmx metrics
		When I navigate to '/newrelic_singular_app/results/none/load_test/id/key-three/plugin/NewrelicRestPlugin/newrelic'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-three with newrelic jmx metrics
		When I navigate to '/none/results/main/load_test/id/key-three/plugin/NewrelicRestPlugin/newrelic'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"