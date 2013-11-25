Feature: Results Page
	In order to view past results
	As a performance test user
	I want to view the results page for an application

	Scenario: Navigate to results page for atom_hopper (singular) application
		When I navigate to '/atom_hopper/results'
		Then the response should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to results page for overhead (overhead) application
		When I navigate to '/overhead/results'
		Then the response should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to results page for invalid app
		When I navigate to '/invalid/results'
		Then the response should be "404"

	Scenario: Navigate to main sub application results page for atom_hopper (singular) application
		When I navigate to '/atom_hopper/results/main'
		Then the response should be "200"
		And the page should contain "load_test,duration_test,stress_test,adhoc_test" test types

	Scenario: Navigate to main sub application results page for overhead application
		When I navigate to '/overhead/results/main'
		Then the response should be "200"
		And the page should contain "load_test,duration_test,stress_test,adhoc_test" test types

	Scenario: Navigate to invalid application results page
		When I navigate to '/atom_hopper/results/invalid'
		Then the response should be "404"

	Scenario: Navigate to invalid application results page for invalid application
		When I navigate to '/invalid/results/invalid'
		Then the response should be "404"

	Scenario: Navigate to main load results for atom_hopper (singular) application
		When I navigate to '/atom_hopper/results/main/load_test'
		Then the response should be "200"
		And the page should match the "atom_hopper_main_load_test_results" version

	Scenario: Navigate to main load results for overhead application
		When I navigate to '/overhead/results/main/load_test'
		Then the response should be "200"
		And the page should match the "overhead_main_load_test_results" version

	Scenario: Navigate to main load results for repose application
		When I navigate to '/repose/results/main/load_test'
		Then the response should be "200"
		And the page should match the "repose_main_load_test_results" version

	Scenario: Navigate to invalid app main sub app load test application results page
		When I navigate to '/not_found/results/main/load_test'
		Then the response should be "404"

	Scenario: Navigate to atom hopper app invalid sub app load test application results page
		When I navigate to '/atom_hopper/results/invalid/load_test'
		Then the response should be "404"

	Scenario: Navigate to atom_hopper main invalid test application results page
		When I navigate to '/atom_hopper/results/main/invalid_test'
		Then the response should be "404"

	Scenario: Load atom_hopper (singular) main load test average response time metric with test ended
		When I navigate to '/atom_hopper/results/main/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "avg" records in response

	Scenario: Load overhead main load test average response time metric with test ended
		When I navigate to '/overhead/results/main/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "avg" records in response

	Scenario: Load atom_hopper main adhoc test average response time metric with test not ended
		When I navigate to '/atom_hopper/results/main/adhoc_test/metric/avg'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" records in response
		And "fail" json record should equal to "empty metric specified" 

	Scenario: Load atom_hopper (singular) main load test throughput metric with test ended
		When I navigate to '/atom_hopper/results/main/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "throughput" records in response

	Scenario: Load overhead main load test throughput metric with test ended
		When I navigate to '/overhead/results/main/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "throughput" records in response

	Scenario: Load atom_hopper main load test throughput metric with test not ended
		When I navigate to '/atom_hopper/results/main/adhoc_test/metric/throughput'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "throughput" records in response
		And "fail" json record should equal to "empty metric specified" 

	Scenario: Load atom_hopper (singular) main load test errors metric with test ended
		When I navigate to '/atom_hopper/results/main/load_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "errors" records in response

	Scenario: Load overhead main load test errors metric with test ended
		When I navigate to '/overhead/results/main/load_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "errors" records in response

	Scenario: Load atom_hopper main load test invalid metric with test ended
		When I navigate to '/atom_hopper/results/main/load_test/metric/invalid'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "empty metric specified" 

	Scenario: Load atom_hopper main invalid test throughput metric with test ended
		When I navigate to '/atom_hopper/results/main/invalid/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid test specified"

	Scenario: Load atom_hopper invalid load test throughput metric with test ended
		When I navigate to '/atom_hopper/results/invalid/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid sub app specified"

	Scenario: Load invalid main load test throughput metric with test ended
		When I navigate to '/invalid/results/main/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid application specified"

	Scenario: Load atom hopper (singular) main load test id = e464b1b6-10ab-4332-8b30-8439496c2d19
		When I navigate to '/atom_hopper/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "200"
		And the page should contain the "e464b1b6-10ab-4332-8b30-8439496c2d19" version

	Scenario: Load atom hopper (singular) main load test id = not_found
		When I navigate to '/atom_hopper/results/main/load_test/id/not_found'
		Then the response should be "404"

	Scenario: Load overhead main load test id = some-random-string+some-random2-string
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And the page should contain the "some-random-string" version

	Scenario: Load overhead main load test id = not_found
		When I navigate to '/overhead/results/main/load_test/id/not_found'
		Then the response should be "404"

	Scenario: Load overhead main load test id = some-other-string with one part of test not ended
		When I navigate to '/overhead/results/main/load_test/id/some-other-string'
		Then the response should be "500"
		And the error page should match the "Both sets of results are not yet available"

	Scenario: Load atom hopper (singular) main invalid test id = e464b1b6-10ab-4332-8b30-8439496c2d19
		When I navigate to '/atom_hopper/results/main/invalid/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "404"

	Scenario: Load atom hopper (singular) invalid load test id = e464b1b6-10ab-4332-8b30-8439496c2d19
		When I navigate to '/atom_hopper/results/invalid/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "404"

	Scenario: Load invalid main load test id = e464b1b6-10ab-4332-8b30-8439496c2d19
		When I navigate to '/invalid/results/main/load_test/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "404"

	Scenario: STOPPED HERE!!! Load specific dbaas test for jenkins-repose-pt-static-load-146 with avg metric with test ended
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
