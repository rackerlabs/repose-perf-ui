Feature: Start and Stop Page
	In order to start and stop tests
	As a performance test user
	I want to be able to start and stop tests

	Scenario: Start and stop atom_hopper main load test with jmeter for 60 minutes
	    Given No tests are started for "atom_hopper" "main" "load" 
		When I post to '/atom_hopper/applications/main/load_test/start' with:
		"""
		  {
			"length":60, 
			"description": "this is a description of the test", 
			"flavor_type": "performance", 
			"release": "1.6", 
			"name":"this is my name",
			"runner":"jmeter"
		  }
		""" 
		Then the response should be "200"
		And response should be a json
		And "guid" json record should exist
		And "time" json record should exist
		
		Given Test is started for "atom_hopper" "main" "load"
		When I post to '/atom_hopper/applications/main/load_test/stop' with existing guid:
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    }
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries

	Scenario: Start atom_hopper main load test with jmeter for 60 minutes while another test is running
	    Given Test is started for "atom_hopper" "main" "load"
		When I post to '/atom_hopper/applications/main/load_test/start' with:
		"""
		  {
			"length":60, "description": "this is a description of the test", "flavor_type": "performance", "release": "1.6", "name":"this is my name"
		  }
		""" 
		Then the response should be "400"
		And response should be a json
		And there should be "0" "guid" records in response
		And "fail" json record should equal to "test for atom_hopper/main/load_test already started" 

	Scenario: Start atom_hopper main load test with jmeter for 60 minutes with invalid data
		When I post to '/atom_hopper/applications/main/load_test/start' with:
		"""
		  {
			"flavor_type": "performance", "release": "1.6", "name":"this is my name"
		  }
		""" 
		Then the response should be "400"
		And response should be a json
		And there should be "0" "guid" records in response
		And "fail" json record should equal to "required keys are missing" 

	Scenario: Stop atom_hopper main load test with invalid guid
		Given Test is started for "atom_hopper" "main" "load"
		When I post to '/atom_hopper/applications/main/load_test/stop' with non-existing guid
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    }
		  }
		"""
		Then the response should be "400"
		And response should be a json
		And "result" json record should equal to "not found"
		And the "data" key in redis should not exist
		And the "meta" key in redis should not exist
		And the "configs" key in redis should not exist
		And the "data" directory should not contain "summary.log" file
		And the "meta" directory should not contain "test.jmx" file

	Scenario: Start and stop overhead main load test with jmeter for 60 minutes - initial test
		Given No tests are started for "overhead" "main" "load"
		When I post to '/overhead/applications/main/load_test/start' with: 
		"""
		  {
			"length":60, 
			"description": "this is a description of the test", 
			"flavor_type": "performance", 
			"release": "1.6", 
			"name":"this is my name",
			"runner":"jmeter"
		  }
		""" 
		Then the response should be "200"
		And response should be a json
		And "guid" json record should exist
		And "time" json record should exist
		
		Given Test is started for "overhead" "main" "load" initial test
		When I post to '/overhead/applications/main/load_test/stop' with existing guid:
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    }
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries
		And the "test" json entry for "meta" hash key in redis does not contain "comparison_guid" key and "some-other-string" value
		
	Scenario: Start and stop overhead main load test with jmeter for 60 minutes - secondary test
		Given No tests are started for "overhead" "main" "load"
		When I post to '/overhead/applications/main/load_test/start' with: 
		"""
		  {
			"length":60, 
			"description": "this is a description of the test", 
			"flavor_type": "performance", 
			"release": "1.6", 
			"name":"this is my name",
			"runner":"jmeter",
		    "comparison_guid": "some-other-string"
		  }
		""" 
		Then the response should be "200"
		And response should be a json
		And "guid" json record should exist
		And "time" json record should exist
		
		Given Test is started for "overhead" "main" "load" secondary test
		When I post to '/overhead/applications/main/load_test/stop' with existing guid:
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    }
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries
		And the "test" json entry for "meta" hash key in redis contains "comparison_guid" key and "some-other-string" value

	Scenario: Start overhead main load test with jmeter for 60 minutes with invalid comparison_guid - secondary test
		Given No tests are started for "overhead" "main" "load"
		When I post to '/overhead/applications/main/load_test/start' with: 
		"""
		  {
			"length":60, 
			"description": "this is a description of the test", 
			"flavor_type": "performance", 
			"release": "1.6", 
			"name":"this is my name",
			"runner":"jmeter",
		    "comparison_guid": "invalid-comparison-guid"
		  }
		""" 
		Then the response should be "400"
		And response should be a json
		And there should be "0" "guid" records in response
		And "fail" json record should equal to "test for atom_hopper/main/load_test already started" 

	Scenario: Stop overhead main load test with invalid guid - primary test
		Given Test is started for "overhead" "main" "load"
		When I post to '/overhead/applications/main/load_test/stop' with non-existing guid
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    }
		  }
		"""
		Then the response should be "400"
		And response should be a json
		And "result" json record should equal to "not found"
		And the "data" key in redis should not exist
		And the "meta" key in redis should not exist
		And the "configs" key in redis should not exist
		And the "data" directory should not contain "summary.log" file
		And the "meta" directory should not contain "test.jmx" file

	Scenario: Stop overhead main load test with invalid data
		Given Test is started for "overhead" "main" "load"
		When I post to '/overhead/applications/main/load_test/stop' with non-existing guid
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          }
		    }
		  }
		"""
		Then the response should be "400"
		And response should be a json
		And "result" json record should equal to "not found"
		And the "data" key in redis should not exist
		And the "meta" key in redis should not exist
		And the "configs" key in redis should not exist
		And the "data" directory should not contain "summary.log" file
		And the "meta" directory should not contain "test.jmx" file
