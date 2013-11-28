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

	Scenario: Load atom hopper (singular) main load test id = e464b1b6-10ab-4332-8b30-8439496c2d19 avg metric
		When I navigate to '/atom_hopper/results/main/load_test/metric/avg/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "200"
		And response should be a json
		And there should be "620" "avg" records in response

	Scenario: Load atom hopper (singular) main load test id = e464b1b6-10ab-4332-8b30-8439496c2d19 throughput metric
		When I navigate to '/atom_hopper/results/main/load_test/metric/throughput/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "200"
		And response should be a json
		And there should be "620" "throughput" records in response

	Scenario: Load atom hopper (singular) main load test id = e464b1b6-10ab-4332-8b30-8439496c2d19 errors metric
		When I navigate to '/atom_hopper/results/main/load_test/metric/errors/id/e464b1b6-10ab-4332-8b30-8439496c2d19'
		Then the response should be "200"
		And response should be a json
		And there should be "620" "errors" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string avg metric
		When I navigate to '/overhead/results/main/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "avg" "some-random-string" records in response
		And there should be "620" "avg" "some-random2-string" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string throughput metric
		When I navigate to '/overhead/results/main/load_test/metric/throughput/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "throughput" "some-random-string" records in response
		And there should be "620" "throughput" "some-random2-string" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string errors metric
		When I navigate to '/overhead/results/main/load_test/metric/errors/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "errors" "some-random-string" records in response
		And there should be "620" "errors" "some-random2-string" records in response

	Scenario: Load atom hopper (singular) main load test id = not_found errors metric
		When I navigate to '/atom_hopper/results/main/load_test/metric/errors/id/not_found'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "errors" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main load test id = not_found errors metric
		When I navigate to '/overhead/results/main/load_test/metric/errors/id/not_found'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "errors" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main load test id = some-other-string errors metric
		When I navigate to '/overhead/results/main/load_test/metric/errors/id/some-other-string'
		Then the response should be "500"
		And the error page should match the "Both sets of results are not yet available"

	Scenario: Load overhead main load test id = some-random-string+some-random2-string invalid metric
		When I navigate to '/overhead/results/main/load_test/metric/invalid/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "invalid" "some-random-string" records in response
		And there should be "0" "invalid" "some-random2-string" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main invalid test id = some-random-string+some-random2-string avg metric
		When I navigate to '/overhead/results/main/invalid/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead invalid load test id = some-random-string+some-random2-string avg metric
		When I navigate to '/overhead/results/invalid/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load invalid main load test id = some-random-string+some-random2-string avg metric
		When I navigate to '/invalid/results/main/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Download atom hopper main load test e464b1b6-10ab-4332-8b30-8439496c2d19 test runner file
		When I click on '/atom_hopper/results/main/load_test/e464b1b6-10ab-4332-8b30-8439496c2d19/test_download/jmeter'
		Then the response should be "200"
		And the download page should match the "jmeter_main" version

	Scenario: Download overhead main load test some-random-string test runner file
		When I click on '/overhead/results/main/load_test/some-random-string/test_download/jmeter'
		Then the response should be "200"
		And the download page should match the "jmeter_main" version

	Scenario: Download overhead main load test some-other-string test runner file
		When I click on '/overhead/results/main/load_test/some-other-string/test_download/jmeter'
		Then the response should be "200"
		And the download page should match the "jmeter_main" version

	Scenario: Download overhead main load test not-found test runner file
		When I click on '/overhead/results/main/load_test/not-found/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for overhead/main/not-found"

	Scenario: Download overhead main invalid test some-other-string test runner file
		When I click on '/overhead/results/main/invalid/some-other-string/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for overhead/main"

	Scenario: Download overhead invalid load test some-other-string test runner file
		When I click on '/overhead/results/invalid/load_test/some-other-string/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for overhead/invalid"

	Scenario: Download invalid main load test some-other-string test runner file
		When I click on '/invalid/results/main/load_test/some-other-string/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for invalid/main"

	Scenario: Compare comparison_app main load test key-one and key-two
		When I post to "/comparison_app/results/main/load_test" with '{"compare":"key-one+key-two"}'
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load" version

	Scenario: Compare comparison_app main load test key-one and unknown
		When I post to "/comparison_app/results/main/load_test" with '{"compare":"key-one+unknown"}'
		Then the response should be "200"
		And the page should match the "compare_app_compare_main_load_unknown" version

	Scenario: Compare comparison_app main invalid test key-one and key-two
		When I post to "/comparison_app/results/main/invalid" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error page should match the "No application by name of comparison_app/invalid found"
		
	Scenario: Compare comparison_app invalid load test key-one and key-two
		When I post to "/comparison_app/results/invalid/load_test" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error page should match the "No sub application for invalid found"

	Scenario: Compare invalid main load test key-one and key-two
		When I post to "/invalid/results/main/load_test" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error page should match the "No application by name of invalid/load_test found"

	Scenario: Compare comparison_app main load test key-one and key-two for avg
		When I navigate to '/comparison_app/results/main/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "avg" "key-one" records in response
		And there should be "620" "avg" "key-two" records in response

	Scenario: Compare comparison_app main load test key-one and key-two for unknown
		When I navigate to '/comparison_app/results/main/load_test/metric/unknown/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Compare comparison_app main invalid test key-one and key-two for avg
		When I navigate to '/comparison_app/results/main/invalid/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "The metric data is empty" 
		
	Scenario: Compare comparison_app invalid load test key-one and key-two for avg
		When I navigate to '/comparison_app/results/invalid/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Compare invalid main load test key-one and key-two for avg
		When I navigate to '/invalid/results/main/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "The metric data is empty" 




