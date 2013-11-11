Feature: Results Page
	In order to view past results
	As a performance test user
	I want to view the results page for an application

	Scenario: Navigate to results page for atom_hopper application
		When I navigate to '/atom_hopper/results'
		Then the response should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to results page for invalid app
		When I navigate to '/invalid/results'
		Then the response should be "404"

	Scenario: Navigate to main sub application results page for atom_hopper application
		When I navigate to '/atom_hopper/results/main'
		Then the response should be "200"
		And the page should contain "load_test,duration_test,stress_test,adhoc_test" test types

	Scenario: Navigate to invalid application results page
		When I navigate to '/atom_hopper/results/invalid'
		Then the response should be "404"

	Scenario: Navigate to invalid application results page for invalid application
		When I navigate to '/invalid/results/invalid'
		Then the response should be "404"

	Scenario: Navigate to main load results for atom_hopper application
		When I navigate to '/atom_hopper/results/main/load_test'
		Then the response should be "200"
		And the page should match the "dbaas_load_test_results" version

	Scenario: Navigate to dbaas duration test application results page
		When I navigate to '/results/dbaas/duration_test'
		Then the response should be "200"
		And the page should match the "dbaas_duration_test_results" version

	Scenario: Navigate to invalid app load test application results page
		When I navigate to '/results/invalid/load_test'
		Then the response should be "404"

	Scenario: Navigate to dbaas invalid test application results page
		When I navigate to '/results/dbaas/invalid_test'
		Then the response should be "404"

	Scenario: Load dbaas load test average response time metric with test ended
		When I navigate to '/results/dbaas/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "1" tests in response

	Scenario: Load dbaas adhoc test average response time metric with test not ended
		When I navigate to '/results/dbaas/adhoc_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load dbaas load test throughput metric
		When I navigate to '/results/dbaas/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "1" tests in response

	Scenario: Load dbaas adhoc test throughput metric with test not ended
		When I navigate to '/results/dbaas/adhoc_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load dbaas adhoc test errors metric
		When I navigate to '/results/dbaas/adhoc_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load dbaas load test invalid metric
		When I navigate to '/results/dbaas/load_test/metric/invalid'
		Then the response should be "200"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load dbaas invalid test errors metric
		When I navigate to '/results/dbaas/invalid_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load invalid app load test errors metric
		When I navigate to '/results/invalid/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And there should be "0" tests in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with test ended
		When I navigate to '/results/dbaas/load_test/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And the page should contain the "dbaas_load_test_id_jenkins-repose-pt-static-adhoc-146" version

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with test not ended
		When I navigate to '/results/dbaas/adhoc_test/id/jenkins-repose-pt-static-adhoc-146/date/1377583327000'
		Then the response should be "404"
		And the error page should match the "Both repose and origin results are not yet available"

	Scenario: Load specific dbaas test where id does not exist
		When I navigate to '/results/dbaas/load_test/id/jenkins-repose-pt-static-load-/date/1377583327000'
		Then the response should be "404"
		And the error page should match the "Both repose and origin results are not yet available"

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 where date does not exist (blank)
		When I navigate to '/results/dbaas/load_test/id/jenkins-repose-pt-static-load-146/date/1'
		Then the response should be "200"
		And the page should contain the "dbaas_load_test_id_jenkins-repose-pt-static-adhoc-146-no-date" version

	Scenario: Load specific dbaas test invalid test type for jenkins-repose-pt-static-load-146
		When I navigate to '/results/dbaas/invalid_test/id/jenkins-repose-pt-static-load-/date/1377583327000'
		Then the response should be "404"

	Scenario: Load specific invalid test for jenkins-repose-pt-static-load-146
		When I navigate to '/results/dbaas/invalid_test/id/jenkins-repose-pt-static-load-/date/1377583327000'
		Then the response should be "404"

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with avg metric with test ended
		When I navigate to '/results/dbaas/load_test/metric/avg/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "602" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-adhoc-146 with avg metric with test not ended
		When I navigate to '/results/dbaas/adhoc_test/metric/avg/id/jenkins-repose-pt-static-adhoc-146/date/1377583327000'
		Then the response should be "404"
		And the error page should match the "Both repose and origin results are not yet available"

	Scenario: Load specific dbaas test where id does not exist with avg metric
		When I navigate to '/results/dbaas/load_test/metric/avg/id/jenkins-repose-pt-static-load-/date/1377583327000'
		Then the response should be "404"
		And the error page should match the "Both repose and origin results are not yet available"

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with invalid metric
		When I navigate to '/results/dbaas/load_test/metric/invalid/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "0" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with avg metric with invalid date
		When I navigate to '/results/dbaas/load_test/metric/avg/id/jenkins-repose-pt-static-load-146/date/1'
		Then the response should be "200"
		And response should be a json
		And there should be "601" "repose" records in response
		And there should be "602" "origin" records in response

	Scenario: Load specific dbaas test for jenkins-repose-pt-static-load-146 with avg metric with invalid test type
		When I navigate to '/results/dbaas/invalid_test/metric/avg/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "404"

	Scenario: Load specific invalid app for jenkins-repose-pt-static-load-146 with avg metric
		When I navigate to '/results/invalid/load_test/metric/avg/id/jenkins-repose-pt-static-load-146/date/1377583327000'
		Then the response should be "404"

	Scenario: Load specific ddrl test for jenkins-repose-pt-static-load-147 with avg metric with test ended with no origin
		When I navigate to '/results/ddrl/load_test/metric/avg/id/jenkins-repose-pt-static-load-147/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "602" "repose" records in response
		And there should be "0" "origin" records in response

	Scenario: Load specific ddrl test for jenkins-repose-pt-static-load-148 with avg metric with test ended with no repose
		When I navigate to '/results/ddrl/load_test/metric/avg/id/jenkins-repose-pt-static-load-148/date/1377583327000'
		Then the response should be "200"
		And response should be a json
		And there should be "0" "repose" records in response
		And there should be "602" "origin" records in response

	Scenario: Download dbaas test runner file
		When I click on '/results/dbaas/load_test/jenkins-repose-pt-static-load-146/test_download/test_dbaas.jmx'
		Then the response should be "200"
		And the download page should match the "jmeter_dbaas_jenkins-repose-pt-static-load-146" version

	Scenario: Download invalid test id runner file
		When I click on '/results/dbaas/load_test/jenkins-repose-pt-static-notfound-146/test_download/test_notfound.jmx'
		Then the response should be "404"
		And the error page should match the "Both repose and origin results are not yet available"

	Scenario: Download invalid test runner file
		When I click on '/results/invalid/load_test/jenkins-repose-pt-static-load-146/test_download/test_notfound.jmx'
		Then the response should be "404"

	Scenario: Compare jenkins-repose-pt-static-load-146 and jenkins-repose-pt-static-load-149 for dbaas load test
		When I post to "/results/dbaas/load_test" with "jenkins-repose-pt-static-load-146,jenkins-repose-pt-static-load-149"
		Then the response should be "200"
		And the page should match the "compare_dbaas_load" version

	Scenario: Compare jenkins-repose-pt-static-load-146 and unknown for dbaas load test
		When I post to "/results/dbaas/load_test" with "jenkins-repose-pt-static-load-146,unknown"
		Then the response should be "200"
		And the page should match the "compare_dbaas_load" version

	Scenario: Compare jenkins-repose-pt-static-load-146 and jenkins-repose-pt-static-load-149 for dbaas unknown test
		When I post to "/results/dbaas/unkown" with "jenkins-repose-pt-static-load-146,jenkins-repose-pt-static-load-149"
		Then the response should be "404"

	Scenario: Compare jenkins-repose-pt-static-load-146 and jenkins-repose-pt-static-load-149 for invalid app load test
		When I post to "/results/unknown/load_test" with "jenkins-repose-pt-static-load-146,jenkins-repose-pt-static-load-149"
		Then the response should be "404"
