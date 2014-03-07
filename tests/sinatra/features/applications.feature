@application
Feature: Application Page
	In order to view applications
	As a performance test user
	I want to view the sub applications page for each application

	Scenario: Navigate to sub applications page of comparison_app application
		Given I navigate to '/comparison_app'
		When I click on "Applications"
		Then the page response status code should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to sub applications page of invalid application
		When I navigate to '/invalid/applications'
		Then the page response status code should be "404"

	Scenario: Navigate to main application
		Given I navigate to '/comparison_app/applications'
		When I click on 'main'
		Then the page response status code should be "200"
		And the page should contain "config1_xml" configuration

	Scenario: Download main test runner file
		Given I navigate to '/comparison_app/applications/main'
		When I click on "jmeter_load"
		Then the page response status code should be "200"
		And the page should have "text/html;charset=utf-8" "content-type" header
		And download file name should be "test_file"

	Scenario: Navigate to invalid sub application of comparison_app application
		When I navigate to '/comparison_app/applications/invalid'
		Then the page response status code should be "404"

	Scenario: Navigate to main sub application of repose application, which doesn't have requests and responses
		When I navigate to '/overhead/applications/main'
		Then the page response status code should be "500"
		Then the page should contain "required requests and response jsons are not available. These files are required to let users know what execution happens during a test run."

	Scenario: Navigate to main sub application of no_store application, which has a misconfigured file store
		When I navigate to '/no_store/applications/main'
		Then the page response status code should be "500"
		And the page should contain "Unable to gather required data. There's a misconfiguration to connect to backend services."

	Scenario: Navigate to invalid sub application of invalid application
		When I navigate to '/invalid/applications/invalid'
		Then the page response status code should be "404"

	Scenario: Download invalid test runner file
		When I navigate to '/comparison_app/applications/not_found/test_download/jmeter'
		Then the page response status code should be "404"
		And the page should contain "No test script exists for comparison_app/not_found"

	Scenario: Download test runner file from invalid application
		When I click on '/invalid/applications/not_found/test_download/jmeter'
		Then the response should be "404"
		And the error should match the "No test script exists for invalid/not_found"

	@update_application
	Scenario: Add a new config to comparison app application
	    Given "1" config files exist in "comparison_app" "main" application
		When I upload "/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log" config file to "comparison_app" "main" application
		Then the page response status code should be "201"
		And the "comparison_app:main:setup:configs" list should contain "2" json entries in redis for "comparison_app" "main"
		And the "comparison_app/main/setup/configs" directory should contain "summary.log" file
		And the page should contain "config1"
		And the page should contain "summary_log"
		And remove "summary_log" config from "comparison_app" "main"

	@update_application
	Scenario: Remove a config from comparison app application
		Given "config2" config file exists in "comparison_app" "main" application
	    And "2" config files exist in "comparison_app" "main" application
	    When I navigate to '/comparison_app/applications/main/update'
		And I remove "config_config2" config file
		Then the page response status code should be "200"
		And the "comparison_app:main:setup:configs" list should contain "1" entries in redis for "comparison_app" application
		And the "comparison_app/main/setup/configs" directory should contain "1" entries for "comparison_app" application
		And the page should contain "config1"
		And the page should not contain "config2"

	@update_application
	Scenario: Navigate to update of unknown sub app
	    	When I navigate to '/comparison_app/applications/unknown/update'
 		Then the page response status code should be "404"

	@update_application
	Scenario: Navigate to update of unknown sub app
	    	When I navigate to '/unknown/applications/main/update'
 		Then the page response status code should be "404"

	@update_application
	Scenario: Update test in comparison app application
		Given "0" "gatling" "load" test files exist in "comparison_app" "main" application
		When I navigate to '/comparison_app/applications/main/update'
		And I select "gatling" "test_file_runner"
		And I select "Load Test" "test_file_type"
		And I upload "/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log" test file
		Then the page response status code should be "201"
		And the "comparison_app:main:tests:setup:script" list should contain "2" entries in redis for "comparison_app" application
		And the "comparison_app/main/setup/meta" directory should contain "2" entries for "comparison_app" application
		And the page should contain "jmeter_load"
		And the page should contain "gatling_load"
		And remove "summary.log" "gatling" "load" test file for "comparison_app" "main"

	@update_application
	Scenario: Remove test in comparison app application
		Given "gatling" "load" test file exists in "comparison_app" "main" application
	    And "2" "gatling" "load" test files exist in "comparison_app" "main" application
		When I remove "test_file|||gatling_load" test file from "comparison_app" "main" application
		Then the page response status code should be "200"
		And the "comparison_app:main:tests:setup:script" list should contain "1" entries in redis for "comparison_app" application
		And the "comparison_app/main/setup/meta" directory should contain "1" entries for "comparison_app" application
		And the page should contain "jmeter_load"
		And the page should not contain "gatling_load"

	@update_application
	Scenario: Add existing config in comparison app application
	    Given "1" config files exist in "comparison_app" "main" application
		When I upload "/Users/dimi5963/projects/lighttpd/data/files/comparison_app/main/setup/configs/config1.xml" config file to "comparison_app" "main" application
		Then the page response status code should be "404"
		And the error page should match the "invalid config file specified"
		And the "comparison_app:main:setup:configs" list should contain "1" entries in redis for "comparison_app" application
		And the "comparison_app/main/setup/configs" directory should contain "1" entries for "comparison_app" application

	@update_application
	Scenario: Add new request in comparison app application unknown sub app
		When I post to "/comparison_app/applications/unknown/add_request_response" with:
		"""
		  {
			"request":{
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"response_code": 200
			}
		  }
		"""
		Then the response should be "404"

	@update_application
	Scenario: Add new request in comparison app application
		When I post to "/unknown/applications/main/add_request_response" with:
		"""
		  {
			"request":{
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"response_code": 200
			}
		  }
		"""
		Then the response should be "404"

	@update_application
	Scenario: Add new request in comparison app application
		Given "2" request exists in "comparison_app" "main" application
		And "2" response exists in "comparison_app" "main" application
		When I post to "/comparison_app/applications/main/add_request_response" with:
		"""
		  {
			"request":{
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"response_code": 200
			}
		  }
		"""
		Then the response should be "201"
		And the "comparison_app:main:tests:setup:request_response:request" json list should have "3" entries in redis for "comparison_app"
		And the "comparison_app:main:tests:setup:request_response:response" json list should have "3" entries in redis for "comparison_app"
		And the "comparison_app:main:tests:setup:request_response:request" json list should contain "uri" key with "/test" value in redis for "comparison_app"
		And the message should contain "/test"
		And remove "request_id" "3" from redis "comparison_app:main:tests:setup:request_response:request" key for "comparison_app"
		And remove "request_id" "3" from redis "comparison_app:main:tests:setup:request_response:response" key for "comparison_app"

	@update_applications
	Scenario: Update request in comparison app application and unknown sub app
		When I post to "/comparison_app/applications/unknown/update_request_response" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"

	@update_applications
	Scenario: Update request in unknown app application
		When I post to "/unknown/applications/main/update_request_response" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"

	@update_applications
	Scenario: Update request in comparison app application
		When I post to "/comparison_app/applications/main/update_request_response" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "200"
		And the "comparison_app:main:tests:setup:request_response:request" json list should have "2" entries in redis for "comparison_app"
		And the "comparison_app:main:tests:setup:request_response:request" json list should contain "uri" key with "/test" value in redis for "comparison_app"
		And the "comparison_app:main:tests:setup:request_response:response" json list should have "2" entries in redis for "comparison_app"
		And update "request_id" "1" from redis "comparison_app:main:tests:setup:request_response:request" key for "comparison_app":
		"""
			{
				"request_id":1,
				"method":"GET",
				"uri":"/v1.0/{user}/flavors",
				"headers":[
					"x-auth-token: valid-admin-token${user}",
					"x-auth-project-id: test",
					"accept: application/json"
				]
			}
		"""
		And update "request_id" "1" from redis "comparison_app:main:tests:setup:request_response:response" key for "comparison_app":
		"""
			{
				"request_id":1,
				"response_code":200
			}
		"""

	@update_application
	Scenario: Remove all requests in comparison app application
		When I delete from "/comparison_app/applications/main/remove_request_response/1"
		Then the response should be "200"
		And response should be a json
		And the "comparison_app:main:tests:setup:request_response:request" json list should have "1" entries in redis for "comparison_app"
		And the "comparison_app:main:tests:setup:request_response:response" json list should have "1" entries in redis for "comparison_app"
		And add "request_id" "1" from redis "comparison_app:main:tests:setup:request_response:request" key for "comparison_app":
		"""
			{
				"request_id":1,
				"method":"GET",
				"uri":"/v1.0/{user}/flavors",
				"headers":[
					"x-auth-token: valid-admin-token${user}",
					"x-auth-project-id: test",
					"accept: application/json"
				]
			}
		"""
		And add "request_id" "1" from redis "comparison_app:main:tests:setup:request_response:response" key for "comparison_app":
		"""
			{
				"request_id":1,
				"response_code":200
			}
		"""

	@update_application
	Scenario: Remove all requests in comparison app application and unknown app
		When I delete from "/comparison_app/applications/unknown/remove_request_response/1"
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Remove all requests in unknown app application
		When I delete from "/unknown/applications/main/remove_request_response/1"
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Upload config in comparison app application and unknown app
		When I post to "/comparison_app/applications/unknown/upload_config" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Upload config in unknown app application
		When I post to "/unknown/applications/main/upload_config" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Remove config in comparison app application and unknown app
		When I post to "/comparison_app/applications/unknown/remove_config" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Remove config in unknown app application
		When I post to "/unknown/applications/main/remove_config" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Upload test file in comparison app application and unknown app
		When I post to "/comparison_app/applications/unknown/upload_test_file" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Upload test file in unknown app application
		When I post to "/unknown/applications/main/upload_test_file" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Remove test file in comparison app application and unknown app
		When I post to "/comparison_app/applications/unknown/remove_test_file" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json

	@update_application
	Scenario: Remove test file in unknown app application
		When I post to "/unknown/applications/main/remove_test_file" with:
		"""
		  {
			"request":{
				"request_id": 1,
			  	"method": "GET",
			  	"uri": "/test"
			},
			"response": {
				"request_id": 1,
				"response_code": 204
			}
		  }
		"""
		Then the response should be "404"
		And response should be a json
