Feature: Load Jenkins Plugin Page
	In order to load rest plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with Jenkins jmx data stored
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"jenkins_rest_plugin",
			    "type":"flat",
		        "servers":[
  			      {
				    "host":"jenkins.ohthree.com",
				    "job": "Gabe-Compute-Preprod-Smoke",
				    "build": 1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"invalid_id",
			    "type":"flat",
		        "servers":[
  			      {
				    "host":"jenkins.ohthree.com",
				    "job": "Gabe-Compute-Preprod-Smoke",
				    "build": 1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should not contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"jenkins_rest_plugin",
		        "type":"flat",
		        "servers":[
  			      {
				    "host":"invalid",
				    "job": "Gabe-Compute-Preprod-Smoke",
				    "build": 1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And "with_errors" list has "jenkins_rest_plugin" record, which should contain "getaddrinfo: nodename nor servname provided, or not known"
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should not contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with invalid job
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"jenkins_rest_plugin",
		        "type":"flat",
		        "servers":[
  			      {
				    "host":"jenkins.ohthree.com",
				    "job": "invalid",
				    "build": 1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And "with_errors" list has "jenkins_rest_plugin" record, which should contain "404 Resource Not Found"
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should not contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with missing build
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"jenkins_rest_plugin",
		        "type":"flat",
		        "servers":[
  			      {
				    "host":"jenkins.ohthree.com",
				    "job": "Gabe-Compute-Preprod-Smoke",
				    "build": -1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And "with_errors" list has "jenkins_rest_plugin" record, which should equal to "404 Resource Not Found"
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should not contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop jenkins_singular_app main load test with jmeter for 60 minutes with missing type
		Given Test is started for "jenkins_singular_app" "main" "load"
		When I post to '/jenkins_singular_app/applications/main/load_test/stop' with existing guid:
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
		    },
		    "plugins":
		    [
		      {
		        "id":"jenkins_rest_plugin",
		        "servers":[
  			      {
				    "host":"jenkins.ohthree.com",
				    "job": "Gabe-Compute-Preprod-Smoke",
				    "build": 1
				  }
				]		            
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "jenkins_rest_plugin|flat|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should not exist
		And the "jenkins_rest_plugin|time_series|jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/jenkins_rest_plugin" directory should contain "jenkinsdata.out_jenkins.ohthree.com_Gabe-Compute-Preprod-Smoke_1" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "cbu_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

		