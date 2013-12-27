Feature: Load Graphite Plugin Page
	In order to load graphite plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop graphite_singular_app main load test with jmeter for 60 minutes with Graphite jmx data stored
		Given Test is started for "graphite_singular_app" "main" "load"
		When I post to '/graphite_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"graphite_rest_plugin",
		        "servers":[
  			      {
				    "server":"graphite.drivesrvr-dev.com",
				    "target":[
				      "carbon.agents.graphite-a.cpuUsage",
				      "carbon.agents.graphite-a.memUsage"
				    ]
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
		And the "graphite_rest_plugin|time_series|graphitedata.out_graphite.drivesrvr-dev.com" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/graphite_rest_plugin" directory should contain "graphitedata.out_graphite.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop graphite_singular_app main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "graphite_singular_app" "main" "load"
		When I post to '/graphite_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "servers":[
  			      {
				    "server":"graphite.drivesrvr-dev.com",
				    "target":[
				      "carbon.agents.graphite-a.cpuUsage",
				      "carbon.agents.graphite-a.memUsage"
				    ]
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
		And the "graphite_rest_plugin|time_series|graphitedata.out_graphite.drivesrvr-dev.com" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/graphite_rest_plugin" directory should not contain "graphitedata.out_graphite.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop graphite_singular_app main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "graphite_singular_app" "main" "load"
		When I post to '/graphite_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"graphite_rest_plugin",
		        "servers":[
  			      {
				    "server":"invalid-graphite-server",
				    "target":[
				      "carbon.agents.graphite-a.cpuUsage",
				      "carbon.agents.graphite-a.memUsage"
				    ]
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
		And "with_errors" list has "graphite_rest_plugin" record, which should equal to "getaddrinfo: nodename nor servname provided, or not known"
		And the "graphite_rest_plugin|time_series|graphitedata.out_graphite.drivesrvr-dev.com" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/graphite_rest_plugin" directory should not contain "graphitedata.out_graphite.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries