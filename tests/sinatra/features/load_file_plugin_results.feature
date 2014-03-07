Feature: Load File Plugin Page
	In order to load file plugin data on test stop
	As a performance test user
	I want to save the file data

	Scenario: Stop file_singular_app main load test with jmeter for 60 minutes with File data stored
		Given Test is started for "file_singular_app" "main" "load"
		When I post to '/file_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"file_plugin",
		        "type":"blob",
		        "servers":[
  			      {
				    "server":"localhost",
				    "user":"dimi5963",
				    "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/jmxdata.out_162.209.99.50"
			  	},
			  	{
				    "server":"162.209.124.167",
				    "user":"root",
				    "path":"/home/repose/logs/repose.log"
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
		And the "file_plugin|blob|jmxdata.out_162.209.99.50_localhost" json entry for "data" hash key in redis should exist
		And the "file_plugin|blob|repose.log_162.209.124.167" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/file_plugin" directory should contain "jmxdata.out_162.209.99.50_localhost" result file
		And the "data/file_plugin" directory should contain "repose.log_162.209.124.167" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "ah_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop file_singular_app main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "file_singular_app" "main" "load"
		When I post to '/file_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "type":"blob",
		        "servers":[
  			      {
				    "server":"localhost",
				    "user":"dimi5963",
				    "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/jmxdata.out_162.209.99.50"
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
		And the "file_plugin|blob|jmxdata.out_162.209.99.50" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/file_plugin" directory should not contain "jmxdata.out_162.209.99.50" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "ah_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop file_singular_app main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "file_singular_app" "main" "load"
		When I post to '/file_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"file_plugin",
		        "type":"blob",
		        "servers":[
  			      {
				    "server":"invalid",
				    "user":"dimi5963",
				    "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/jmxdata.out_162.209.99.50"
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
		And "with_errors" list has "file_plugin" record, which should equal to "getaddrinfo: nodename nor servname provided, or not known"
		And the "file_plugin|blob|jmxdata.out_162.209.99.50" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/file_plugin" directory should not contain "jmxdata.out_162.209.99.50" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "ah_perftest.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries
