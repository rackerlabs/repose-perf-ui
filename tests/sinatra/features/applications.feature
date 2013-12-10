Feature: Application Page
	In order to view applications
	As a performance test user
	I want to view the sub applications page for each application

	Scenario: Navigate to sub applications page of atom_hopper application
		When I navigate to '/atom_hopper/applications'
		Then the response should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to sub applications page of invalid application
		When I navigate to '/invalid/applications'
		Then the response should be "404"

	Scenario: Navigate to main application
		When I navigate to '/atom_hopper/applications/main'
		Then the response should be "200"
		And the page should contain "config1_xml" configuration

	Scenario: Download main test runner file
		When I click on '/atom_hopper/applications/main/test_download/jmeter'
		Then the response should be "200"
		And the download page should match the "jmeter_main" version

	Scenario: Navigate to invalid sub application of atom_hopper application
		When I navigate to '/atom_hopper/applications/invalid'
		Then the response should be "404"

	Scenario: Navigate to main sub application of repose application, which doesn't have requests and responses
		When I navigate to '/overhead/applications/main'
		Then the page should match the "response_and_requests_not_found" version

	Scenario: Navigate to main sub application of no_store application, which has a misconfigured file store
		When I navigate to '/no_store/applications/main'
		Then the page should match the "misconfigured_file_store" version

	Scenario: Navigate to invalid sub application of invalid application
		When I navigate to '/invalid/applications/invalid'
		Then the response should be "404"

	Scenario: Download invalid test runner file
		When I click on '/atom_hopper/applications/not_found/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for atom_hopper/not_found"

	Scenario: Download test runner file from invalid application
		When I click on '/invalid/applications/not_found/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for invalid/not_found"
		
	Scneario: Navigate to atom hopper main update application
		When I navigate to '/atom_hopper/applications/main/update'
		Then the response should be "200"
		And the page should match the "atom_hopper_application_update" version
		
	Scenario: Add a new config to atom hopper application
		When I upload "config2" config file to "atom_hopper" "main" application
		Then the response should be "201"		
		And response should be a json
		And the "atom_hopper:main:setup:configs" list should contain "2" entries in redis
		And the "atom_hopper/main/setup/configs" directory should contain "config2" file
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Remove a config from atom hopper application
		Given "config2" config file exists in "atom_hopper" "main" application
		When I remove "config2" config file from "atom_hopper" "main" application
		Then the response should be "204"		
		And response should be a json
		And the "atom_hopper:main:setup:configs" list should contain "0" entries in redis
		And the "atom_hopper/main/setup/configs" directory should be empty
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Update test in atom hopper application
		When I upload "gatling" test file to "atom_hopper" "main" application
		Then the response should be "201"		
		And response should be a json
		And the "atom_hopper:main:setup:script" hash should contain "type" key with "gatling" value in redis
		And the "atom_hopper:main:setup:script" hash should contain "test" key in redis
		And the "atom_hopper/main/setup/meta" directory should contain "gatling" file
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Remove test in atom hopper application
		When I remove "jmeter" test file from "atom_hopper" "main" application
		Then the response should be "400"		
		And response should be a json
		And the "atom_hopper:main:setup:script" hash should contain "type" key with "jmeter" value in redis
		And the "atom_hopper:main:setup:script" hash should contain "test" key in redis
		And the "atom_hopper/main/setup/meta" directory should contain "test.jmx" file
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Add existing config in atom hopper application
		When I upload "config1" config file to "atom_hopper" "main" application
		Then the response should be "400"		
		And response should be a json
		And the "atom_hopper:main:setup:configs" list should contain "1" entries in redis
		And the "atom_hopper/main/setup/configs" directory should contain "config1" file
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Add new request in atom hopper application
		When I post to "/atom_hopper/applications/main/update" with:
		"""
		  {
			"request":"test request", 
			"response": "test response"
		  }
		"""
		Then the response should be "201"		
		And response should be a json
		And the "atom_hopper:main:setup:request_response:request" json list should have "3" entries in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "method" key with "GET" value in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "url" key with "/test" value in redis
		And the "atom_hopper:main:setup:request_response:response" json list should have "3" entries in redis
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Update request in atom hopper application
		When I post to "/atom_hopper/applications/main/update" with:
		"""
		  {
		    "request_id": "1",
			"request":"test request", 
			"response": "test response"
		  }
		"""
		Then the response should be "200"		
		And response should be a json
		And the "atom_hopper:main:setup:request_response:request" json list should have "2" entries in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "method" key with "GET" value in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "url" key with "/test" value in redis
		And the "atom_hopper:main:setup:request_response:response" json list should have "2" entries in redis
		And "fail" json record should equal to "No application by name of invalid/load_test found" 
		
	Scenario: Remove all requests in atom hopper application
		When I delete from "/atom_hopper/applications/main/update" with:
		"""
		  {
			"request_list":[1,2]
		  }
		"""
		Then the response should be "400"		
		And response should be a json
		And the "atom_hopper:main:setup:request_response:request" json list should have "2" entries in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "method" key with "GET" value in redis
		And the "atom_hopper:main:setup:request_response:request" json list should contain "url" key with "/test" value in redis
		And the "atom_hopper:main:setup:request_response:response" json list should have "2" entries in redis
		And "fail" json record should equal to "No application by name of invalid/load_test found" 