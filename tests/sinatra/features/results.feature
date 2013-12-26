Feature: Results Page
	In order to view past results
	As a performance test user
	I want to view the results page for an application

	Scenario: Navigate to results page for singular_test (singular) application
		When I navigate to '/singular_test/results'
		Then the page response status code should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to results page for overhead (overhead) application
		When I navigate to '/overhead/results'
		Then the page response status code should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to results page for invalid app
		When I navigate to '/invalid/results'
		Then the page response status code should be "404"

	Scenario: Navigate to main sub application results page for singular_test (singular) application
		When I navigate to '/singular_test/results/main'
		Then the page response status code should be "200"
		And the page should contain "Load Test,Duration Test,Stress Test,Adhoc Test" test types

	Scenario: Navigate to main sub application results page for overhead application
		When I navigate to '/overhead/results/main'
		Then the page response status code should be "200"
		And the page should contain "Load Test,Duration Test,Stress Test,Adhoc Test" test types

	Scenario: Navigate to invalid application results page
		When I navigate to '/singular_test/results/invalid'
		Then the page response status code should be "404"

	Scenario: Navigate to invalid application results page for invalid application
		When I navigate to '/invalid/results/invalid'
		Then the page response status code should be "404"

	Scenario: Navigate to invalid app main sub app load test application results page
		When I navigate to '/not_found/results/main/load_test'
		Then the page response status code should be "404"

	Scenario: Navigate to singular test app invalid sub app load test application results page
		When I navigate to '/singular_test/results/invalid/load_test'
		Then the page response status code should be "404"

	Scenario: Navigate to singular_test main invalid test application results page
		When I navigate to '/singular_test/results/main/invalid_test'
		Then the page response status code should be "404"

	Scenario: Load singular_test (singular) main load test average response time metric with test ended
		When I click on '/singular_test/results/main/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "avg" records in response

	Scenario: Load overhead main load test average response time metric with test ended
		When I click on '/overhead/results/main/load_test/metric/avg'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "avg" records in response

	Scenario: Load singular_test main adhoc test average response time metric with test not ended
		When I click on '/singular_test/results/main/adhoc_test/metric/avg'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" records in response
		And "fail" json record should equal to "invalid metric specified" 

	Scenario: Load singular_test (singular) main load test throughput metric with test ended
		When I click on '/singular_test/results/main/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "throughput" records in response

	Scenario: Load overhead main load test throughput metric with test ended
		When I click on '/overhead/results/main/load_test/metric/throughput'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "throughput" records in response

	Scenario: Load singular_test main load test throughput metric with test not ended
		When I click on '/singular_test/results/main/adhoc_test/metric/throughput'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "throughput" records in response
		And "fail" json record should equal to "invalid metric specified" 

	Scenario: Load singular_test (singular) main load test errors metric with test ended
		When I click on '/singular_test/results/main/load_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "errors" records in response

	Scenario: Load overhead main load test errors metric with test ended
		When I click on '/overhead/results/main/load_test/metric/errors'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "errors" records in response

	Scenario: Load singular_test main load test invalid metric with test ended
		When I click on '/singular_test/results/main/load_test/metric/invalid'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid metric specified" 

	Scenario: Load singular_test main invalid test throughput metric with test ended
		When I click on '/singular_test/results/main/invalid/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid application specified"

	Scenario: Load singular_test invalid load test throughput metric with test ended
		When I click on '/singular_test/results/invalid/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid sub app specified"

	Scenario: Load invalid main load test throughput metric with test ended
		When I click on '/invalid/results/main/load_test/metric/errors'
		Then the response should be "404"
		And response should be a json
		And "fail" json record should equal to "invalid application specified"

	Scenario: Load singular test (singular) main load test id = key-one
		When I navigate to '/singular_test/results/main/load_test/id/key-one'
		Then the page response status code should be "200"
		And the page should contain "Average Response Time"
		And the page should contain "Throughput"
		And the page should contain "Total Errors"
		And the page should contain "3.6 rps"

	Scenario: Load singular test (singular) main load test id = not_found
		When I navigate to '/singular_test/results/main/load_test/id/not_found'
		Then the page response status code should be "404"

	Scenario: Load overhead main load test id = some-random-string+some-random2-string
		When I navigate to '/overhead/results/main/load_test/id/some-random-string+some-random2-string'
		Then the page response status code should be "200"
		And the page should contain "Average Response Time"
		And the page should contain "Throughput"
		And the page should contain "Total Errors"
		And the page should contain "Configurations for some-random-string"
		And the page should contain "Configurations for some-random2-string"
		And the page should contain "3.6 rps"
		And the page should contain "2.1 rps"

	Scenario: Load overhead main load test id = not_found
		When I navigate to '/overhead/results/main/load_test/id/not_found'
		Then the page response status code should be "404"

	Scenario: Load overhead main load test id = some-other-string with one part of test not ended
		When I navigate to '/overhead/results/main/load_test/id/some-other-string'
		Then the page response status code should be "500"
		And the error page should match the "Both sets of results are not yet available"

	Scenario: Load singular test (singular) main invalid test id = key-one
		When I navigate to '/singular_test/results/main/invalid/id/key-one'
		Then the page response status code should be "404"

	Scenario: Load singular test (singular) invalid load test id = key-one
		When I navigate to '/singular_test/results/invalid/load_test/id/key-one'
		Then the page response status code should be "404"

	Scenario: Load invalid main load test id = key-one
		When I navigate to '/invalid/results/main/load_test/id/key-one'
		Then the page response status code should be "404"

	Scenario: Load singular test (singular) main load test id = key-one avg metric
		When I click on '/singular_test/results/main/load_test/metric/avg/id/key-one'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "avg" records in response

	Scenario: Load singular test (singular) main load test id = key-one throughput metric
		When I click on '/singular_test/results/main/load_test/metric/throughput/id/key-one'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "throughput" records in response

	Scenario: Load singular test (singular) main load test id = key-one errors metric
		When I click on '/singular_test/results/main/load_test/metric/errors/id/key-one'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "errors" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string avg metric
		When I click on '/overhead/results/main/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "avg" "some-random-string" records in response
		And there should be "620" "avg" "some-random2-string" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string throughput metric
		When I click on '/overhead/results/main/load_test/metric/throughput/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "throughput" "some-random-string" records in response
		And there should be "620" "throughput" "some-random2-string" records in response

	Scenario: Load overhead main load test id = some-random-string+some-random2-string errors metric
		When I click on '/overhead/results/main/load_test/metric/errors/id/some-random-string+some-random2-string'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "errors" "some-random-string" records in response
		And there should be "620" "errors" "some-random2-string" records in response

	Scenario: Load singular test (singular) main load test id = not_found errors metric
		When I click on '/singular_test/results/main/load_test/metric/errors/id/not_found'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "errors" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main load test id = not_found errors metric
		When I click on '/overhead/results/main/load_test/metric/errors/id/not_found'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "errors" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main load test id = some-other-string errors metric
		When I navigate to '/overhead/results/main/load_test/metric/errors/id/some-other-string'
		Then the page response status code should be "500"
		And the error page should match the "Both sets of results are not yet available"

	Scenario: Load overhead main load test id = some-random-string+some-random2-string invalid metric
		When I click on '/overhead/results/main/load_test/metric/invalid/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "invalid" "some-random-string" records in response
		And there should be "0" "invalid" "some-random2-string" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Load overhead main invalid test id = some-random-string+some-random2-string avg metric
		When I click on '/overhead/results/main/invalid/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "invalid application specified" 

	Scenario: Load overhead invalid load test id = some-random-string+some-random2-string avg metric
		When I click on '/overhead/results/invalid/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "invalid sub app specified" 

	Scenario: Load invalid main load test id = some-random-string+some-random2-string avg metric
		When I click on '/invalid/results/main/load_test/metric/avg/id/some-random-string+some-random2-string'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "some-random-string" records in response
		And there should be "0" "avg" "some-random2-string" records in response
		And "fail" json record should equal to "invalid application specified" 

	Scenario: Download singular test main load test key-one test runner file
		When I navigate to '/singular_test/results/main/load_test/key-one/test_download/jmeter'
		Then the page response status code should be "200"
		And the page should have "text/html;charset=utf-8" "content-type" header
		And download file name should be "test_file"

	Scenario: Download overhead main load test some-random-string test runner file
		When I navigate to '/overhead/results/main/load_test/some-random-string/test_download/jmeter'
		Then the page response status code should be "200"
		And the page should have "text/html;charset=utf-8" "content-type" header
		And download file name should be "test_file"

	Scenario: Download overhead main load test some-other-string test runner file
		When I navigate to '/overhead/results/main/load_test/some-other-string/test_download/jmeter'
		Then the page response status code should be "200"
		And the page should have "text/html;charset=utf-8" "content-type" header
		And download file name should be "test_file"

	Scenario: Download overhead main load test not-found test runner file
		When I navigate to '/overhead/results/main/load_test/not-found/test_download/jmeter'
		Then the page response status code should be "404"
		And the page should contain "No test script exists for overhead/main/not-found"

	Scenario: Download overhead main invalid test some-other-string test runner file
		When I navigate to '/overhead/results/main/invalid/some-other-string/test_download/jmeter'
		Then the page response status code should be "404"
		And the page should contain "No test script exists for overhead/main"

	Scenario: Download overhead invalid load test some-other-string test runner file
		When I navigate to '/overhead/results/invalid/load_test/some-other-string/test_download/jmeter'
		Then the page response status code should be "404"
		And the page should contain "No test script exists for overhead/invalid"

	Scenario: Download invalid main load test some-other-string test runner file
		When I navigate to '/invalid/results/main/load_test/some-other-string/test_download/jmeter'
		Then the page response status code should be "404"
		And the page should contain "No test script exists for invalid/main"

	Scenario: Navigate to main load results for singular_test (singular) application
		When I navigate to '/singular_test/results/main/load_test'
		Then the page response status code should be "200"
		And the page should contain "Average Response Time"
		And the page should contain "Average Throughput"
		And the page should contain "Error Count"
		And the page should contain "Sample Test"
		And the page should contain "45 ms"
		And the page should contain "795.9 rps"

	Scenario: Navigate to main load results for overhead application
		When I navigate to '/overhead/results/main/load_test'
		Then the page response status code should be "200"
		And the page should contain "Average Response Time"
		And the page should contain "Average Throughput"
		And the page should contain "Error Count"
		And the page should contain "jenkins-repose-pt-static-adhoc-231"
		And the page should contain "45 ms"
		And the page should contain "795.9 rps"
		And the page should contain "26.0 ms"
		And the page should contain "Completed"
		And the page should contain "In Progress"

	Scenario: Compare comparison_app main load test key-one and key-two
		Given I navigate to '/comparison_app/results/main/load_test'
		When I check on "key-one"
		And I check on "key-two"
		And I click on "compare_tests_button"
		Then the page response status code should be "200"
		And the page should contain "Average Response Time"
		And the page should contain "Throughput"
		And the page should contain "Error"
		And the page should contain "key-one"
		And the page should contain "key-two"
		And the page source should contain "key-one+key-two"
		And the page should contain "2345 s"
		And the page should contain "3714 s"

	Scenario: Compare comparison_app main load test key-one and unknown
		When I post to "/comparison_app/results/main/load_test" with checkbox name "compare" and values "key-one,unknown"
		Then the response should be "200"
		And the response should contain "key-one+unknown"
		And the response should contain ">key-one</a></td>"
		And the response should not contain ">unknown</a></td>"

	Scenario: Compare comparison_app main invalid test key-one and key-two
		When I post to "/comparison_app/results/main/invalid" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error should match the "No application by name of comparison_app/invalid found"
		
	Scenario: Compare comparison_app invalid load test key-one and key-two
		When I post to "/comparison_app/results/invalid/load_test" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"

	Scenario: Compare invalid main load test key-one and key-two
		When I post to "/invalid/results/main/load_test" with '{"compare":"key-one+key-two"}'
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"

	Scenario: Compare comparison_app main load test key-one and key-two for avg
		When I click on '/comparison_app/results/main/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "200"
		And response should be a json
		And there should be "382" "avg" "key-one" records in response
		And there should be "620" "avg" "key-two" records in response

	Scenario: Compare comparison_app main load test key-one and key-two for unknown
		When I click on '/comparison_app/results/main/load_test/metric/unknown/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "The metric data is empty" 

	Scenario: Compare comparison_app main invalid test key-one and key-two for avg
		When I click on '/comparison_app/results/main/invalid/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "invalid application specified" 
		
	Scenario: Compare comparison_app invalid load test key-one and key-two for avg
		When I click on '/comparison_app/results/invalid/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "invalid sub app specified" 

	Scenario: Compare invalid main load test key-one and key-two for avg
		When I click on '/invalid/results/main/load_test/metric/avg/compare/key-one+key-two'
		Then the response should be "404"
		And response should be a json
		And there should be "0" "avg" "key-one" records in response
		And there should be "0" "avg" "key-two" records in response
		And "fail" json record should equal to "invalid application specified" 