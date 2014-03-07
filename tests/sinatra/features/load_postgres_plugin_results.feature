Feature: Load Postgres Plugin Page
	In order to load postgres plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop postgres_singular_app main load test with jmeter for 60 minutes with Postgres jmx data stored
		Given Test is started for "postgres_singular_app" "main" "load"
		When I post to '/postgres_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"postgres_rest_plugin",
		        "servers":[
  			      {
				    "server":"postgres.drivesrvr-dev.com",
				    "target":[
				      "carbon.agents.postgres-a.cpuUsage",
				      "carbon.agents.postgres-a.memUsage"
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
		And the "postgres_rest_plugin|time_series|postgresdata.out_postgres.drivesrvr-dev.com" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/postgres_rest_plugin" directory should contain "postgresdata.out_postgres.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop postgres_singular_app main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "postgres_singular_app" "main" "load"
		When I post to '/postgres_singular_app/applications/main/load_test/stop' with existing guid:
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
				    "server":"postgres.drivesrvr-dev.com",
				    "target":[
				      "carbon.agents.postgres-a.cpuUsage",
				      "carbon.agents.postgres-a.memUsage"
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
		And the "postgres_rest_plugin|time_series|postgresdata.out_postgres.drivesrvr-dev.com" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/postgres_rest_plugin" directory should not contain "postgresdata.out_postgres.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop postgres_singular_app main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "postgres_singular_app" "main" "load"
		When I post to '/postgres_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"postgres_rest_plugin",
		        "servers":[
  			      {
				    "server":"invalid-postgres-server",
				    "target":[
				      "carbon.agents.postgres-a.cpuUsage",
				      "carbon.agents.postgres-a.memUsage"
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
		And "with_errors" list has "postgres_rest_plugin" record, which should equal to "getaddrinfo: nodename nor servname provided, or not known"
		And the "postgres_rest_plugin|time_series|postgresdata.out_postgres.drivesrvr-dev.com" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/postgres_rest_plugin" directory should not contain "postgresdata.out_postgres.drivesrvr-dev.com" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries