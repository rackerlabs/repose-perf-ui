Feature: JMX Page
	In order to view jmx data
	As a performance test user
	I want to view the jmx results

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with OS jmx metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/os/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with MEMORY jmx metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/memory/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with MEMORY IMPL jmx metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/memoryimpl/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with THREADING jmx metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/threading/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with GC jmx metrics with test ended
		When I navigate to '/results/dbaas/load_test/metric/gc/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "0" "origin" records in response
